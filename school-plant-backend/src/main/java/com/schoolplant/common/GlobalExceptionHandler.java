package com.schoolplant.common;

import cn.dev33.satoken.exception.NotLoginException;
import cn.dev33.satoken.exception.NotRoleException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotLoginException.class)
    public R<?> handleNotLogin(NotLoginException e) {
        return R.fail(401, "请先登录");
    }

    @ExceptionHandler(NotRoleException.class)
    public R<?> handleNotRole(NotRoleException e) {
        return R.fail(403, "无权访问");
    }

    @ExceptionHandler(IllegalStateException.class)
    public R<?> handleIllegalStateException(IllegalStateException e) {
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) {
            msg = "系统配置异常";
        }
        return R.fail(500, msg);
    }

    @ExceptionHandler(org.springframework.web.multipart.MaxUploadSizeExceededException.class)
    public R<?> handleMaxUploadSizeExceededException(org.springframework.web.multipart.MaxUploadSizeExceededException e) {
        return R.fail(400, "上传文件大小超出限制（最大 5MB）");
    }

    @ExceptionHandler(org.springframework.web.multipart.MultipartException.class)
    public R<?> handleMultipartException(org.springframework.web.multipart.MultipartException e) {
        Throwable cur = e;
        while (cur != null) {
            if (cur instanceof org.springframework.web.multipart.MaxUploadSizeExceededException) {
                return R.fail(400, "上传文件大小超出限制（最大 5MB）");
            }
            cur = cur.getCause();
        }

        String msg = e.getMessage();
        if (msg != null && msg.toLowerCase().contains("maximum upload size exceeded")) {
            return R.fail(400, "上传文件大小超出限制（最大 5MB）");
        }
        return R.fail(400, "文件上传请求解析失败");
    }

    @ExceptionHandler(org.springframework.web.bind.MethodArgumentNotValidException.class)
    public R<?> handleMethodArgumentNotValidException(org.springframework.web.bind.MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getAllErrors().get(0).getDefaultMessage();
        return R.fail(400, msg != null ? msg : "参数校验失败");
    }

    @ExceptionHandler(org.springframework.validation.BindException.class)
    public R<?> handleBindException(org.springframework.validation.BindException e) {
        String msg = e.getBindingResult().getAllErrors().get(0).getDefaultMessage();
        return R.fail(400, msg != null ? msg : "参数校验失败");
    }

    @ExceptionHandler(jakarta.validation.ConstraintViolationException.class)
    public R<?> handleConstraintViolationException(jakarta.validation.ConstraintViolationException e) {
        String msg = e.getConstraintViolations().iterator().next().getMessage();
        return R.fail(400, msg != null ? msg : "参数校验失败");
    }

    @ExceptionHandler(Exception.class)
    public R<?> handleException(Exception e) {
        e.printStackTrace();
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) {
            msg = "系统繁忙，请稍后再试";
        }
        return R.fail(msg);
    }
}
