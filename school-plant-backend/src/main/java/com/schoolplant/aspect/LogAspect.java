package com.schoolplant.aspect;

import cn.dev33.satoken.stp.StpUtil;
import com.alibaba.fastjson2.JSON;
import com.schoolplant.annotation.Log;
import com.schoolplant.entity.OperationLog;
import com.schoolplant.entity.User;
import com.schoolplant.service.OperationLogService;
import com.schoolplant.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.DefaultParameterNameDiscoverer;
import org.springframework.expression.EvaluationContext;
import org.springframework.expression.Expression;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.expression.spel.support.StandardEvaluationContext;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.util.List;

@Aspect
@Component
@Slf4j
public class LogAspect {

    @Autowired
    private OperationLogService operationLogService;

    @Autowired
    private UserService userService;
    
    private final ExpressionParser parser = new SpelExpressionParser();
    private final DefaultParameterNameDiscoverer discoverer = new DefaultParameterNameDiscoverer();

    private final ThreadLocal<Long> startTime = new ThreadLocal<>();

    @Pointcut("@annotation(com.schoolplant.annotation.Log)")
    public void logPointCut() {}

    @Before("logPointCut()")
    public void doBefore() {
        startTime.set(System.currentTimeMillis());
    }

    @AfterReturning(pointcut = "logPointCut()", returning = "jsonResult")
    public void doAfterReturning(JoinPoint joinPoint, Object jsonResult) {
        handleLog(joinPoint, null, jsonResult);
    }

    @AfterThrowing(value = "logPointCut()", throwing = "e")
    public void doAfterThrowing(JoinPoint joinPoint, Exception e) {
        handleLog(joinPoint, e, null);
    }

    protected void handleLog(final JoinPoint joinPoint, final Exception e, Object jsonResult) {
        try {
            // Get annotation
            Log controllerLog = getAnnotationLog(joinPoint);
            if (controllerLog == null) {
                return;
            }

            OperationLog operLog = new OperationLog();
            operLog.setOperationResult("SUCCESS");

            Long start = startTime.get();
            if (start != null) {
                operLog.setExecutionTime(System.currentTimeMillis() - start);
            }
            
            // User info
            try {
                if (StpUtil.isLogin()) {
                    Long userId = StpUtil.getLoginIdAsLong();
                    operLog.setUserId(userId);
                    User user = userService.getById(userId);
                    if (user != null) {
                        String name = user.getRealName();
                        if (name == null || name.isEmpty()) {
                            name = user.getUsername();
                        }
                        operLog.setOperatorName(name);
                        // Assuming role is fetched or stored. For simplicity, we might query roles or store current role in session
                        // Here we just put "User" or check admin
                        List<String> roles = StpUtil.getRoleList();
                        operLog.setOperatorRole(roles.isEmpty() ? "USER" : String.join(",", roles));
                    }
                } else {
                    operLog.setOperatorName("匿名用户");
                    operLog.setOperatorRole("GUEST");
                }
            } catch (Exception ex) {
                operLog.setOperatorName("未知用户");
            }

            // Request info
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                operLog.setIpAddress(getClientIp(request));
                operLog.setUserAgent(request.getHeader("User-Agent"));
            }

            // Module info
            operLog.setModule(controllerLog.module());
            operLog.setOperationType(controllerLog.type());
            operLog.setOperationDesc(controllerLog.desc());
            
            // Method arguments
            Object[] args = joinPoint.getArgs();
            try {
                String params = JSON.toJSONString(args);
                operLog.setOperationContent(params.length() > 2000 ? params.substring(0, 2000) : params);
            } catch (Exception ex) {
                // Ignore serialization errors
            }
            
            // Parse Key (Related ID)
            String keyExpression = controllerLog.key();
            if (keyExpression != null && !keyExpression.isEmpty()) {
                try {
                    String key = parseKey(keyExpression, (MethodSignature) joinPoint.getSignature(), args);
                    operLog.setRelatedId(key);
                } catch (Exception ex) {
                    log.warn("Failed to parse key: {}", ex.getMessage());
                }
            }

            if (e != null) {
                operLog.setOperationResult("FAILURE");
                operLog.setErrorMsg(e.getMessage().length() > 2000 ? e.getMessage().substring(0, 2000) : e.getMessage());
            }

            // Save async (or sync for simplicity)
            // operationLogService.save(operLog); // Use saveLog async method if exists, or just save
            // Check if saveLog exists in interface or use save
            // OperationLogServiceImpl has saveLog marked @Async
            operationLogService.saveLog(operLog);

        } catch (Exception exp) {
            log.error("Log aspect error: {}", exp.getMessage());
        } finally {
            startTime.remove();
        }
    }

    private Log getAnnotationLog(JoinPoint joinPoint) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        if (method != null) {
            return method.getAnnotation(Log.class);
        }
        return null;
    }
    
    private String parseKey(String key, MethodSignature methodSignature, Object[] args) {
        if (key == null || key.isEmpty()) return null;
        
        String[] paramNames = discoverer.getParameterNames(methodSignature.getMethod());
        EvaluationContext context = new StandardEvaluationContext();
        if (paramNames != null) {
            for (int i = 0; i < args.length; i++) {
                context.setVariable(paramNames[i], args[i]);
            }
        }
        
        try {
            Expression expression = parser.parseExpression(key);
            Object value = expression.getValue(context);
            return value != null ? value.toString() : null;
        } catch (Exception e) {
            return null;
        }
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        
        // Handle IPv6 localhost
        if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
            return "127.0.0.1";
        }
        
        // Handle multiple IPs in X-Forwarded-For
        if (ip != null && ip.indexOf(",") > 0) {
            ip = ip.substring(0, ip.indexOf(","));
        }
        
        return ip;
    }
}
