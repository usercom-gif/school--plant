package com.schoolplant.controller;

import com.schoolplant.common.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.schoolplant.service.CosStorageService;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Tag(name = "通用接口", description = "通用接口")
@RestController
@RequestMapping("/common")
public class CommonController {

    @Value("${school-plant.profile:./uploads/}")
    private String uploadPath;

    @Value("${server.port:8080}")
    private String port;
    
    @Value("${server.servlet.context-path:/api}")
    private String contextPath;

    @Value("${school-plant.storage:local}")
    private String storage;

    @Autowired(required = false)
    private CosStorageService cosStorageService;

    @Operation(summary = "文件上传")
    @PostMapping("/upload")
    public R<Map<String, String>> upload(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return R.fail("上传文件不能为空");
        }

        if ("cos".equalsIgnoreCase(storage)) {
            if (cosStorageService == null) {
                return R.fail(500, "COS 未启用或未配置密钥：请设置 tencent.cos.enabled=true，并配置环境变量 TENCENT_COS_SECRET_ID 与 TENCENT_COS_SECRET_KEY");
            }
            String originalFilename = file.getOriginalFilename();
            String suffix = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String key = "profile/" + UUID.randomUUID() + suffix;
            String url = cosStorageService.upload(file, key);

            Map<String, String> data = new HashMap<>();
            data.put("url", url);
            data.put("fileName", key);
            data.put("newFileName", key);
            data.put("originalFilename", originalFilename);
            return R.ok(data);
        }

        try {
            // 1. 创建上传目录
            // 使用绝对路径，或者基于项目根目录的路径
            // 如果 uploadPath 以 ./ 开头，将其转换为绝对路径
            File dir;
            if (uploadPath.startsWith("./") || uploadPath.startsWith("../")) {
                dir = new File(System.getProperty("user.dir"), uploadPath);
            } else {
                dir = new File(uploadPath);
            }
            
            // 打印实际路径，方便调试
            System.out.println("上传目录：" + dir.getAbsolutePath());
            
            if (!dir.exists()) {
                boolean created = dir.mkdirs();
                if (!created) {
                     System.out.println("创建目录失败：" + dir.getAbsolutePath());
                     // Try fallback to temp dir if permissions fail
                     // But for now let's just log it
                }
            }

            // 2. 生成文件名
            String originalFilename = file.getOriginalFilename();
            String suffix = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
            String fileName = UUID.randomUUID().toString() + suffix;

            // 3. 保存文件
            // 使用 getAbsolutePath 确保 transferTo 写入正确位置
            File dest = new File(dir.getAbsolutePath(), fileName);
            file.transferTo(dest);

            // 4. 返回访问URL
            String path = contextPath;
            if (path == null || "/".equals(path)) {
                path = "";
            }
            String url = path + "/profile/" + fileName;
            
            Map<String, String> data = new HashMap<>();
            data.put("url", url);
            data.put("fileName", fileName);
            data.put("newFileName", fileName);
            data.put("originalFilename", originalFilename);

            return R.ok(data);

        } catch (IOException e) {
            e.printStackTrace();
            return R.fail("文件上传失败: " + e.getMessage());
        }
    }
}
