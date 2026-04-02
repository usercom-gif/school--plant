package com.schoolplant.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class DifyService {

    @Value("${dify.api.key}")
    private String apiKey;

    @Value("${dify.api.url}")
    private String apiUrl;

    private final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .build();

    /**
     * Analyze plant abnormality image
     * @param imageUrl Publicly accessible URL (if available)
     * @param imageFile Local file (if no public URL)
     * @param userDescription User provided symptom description
     * @return Analysis result
     */
    public String analyzeImage(String imageUrl, File imageFile, String userDescription) {
        try {
            String fileId = null;
            if (imageFile != null) {
                fileId = uploadFile(imageFile);
            }

            // Create Chat Message
            JSONObject requestBody = new JSONObject();
            requestBody.put("inputs", new JSONObject());
            StringBuilder query = new StringBuilder();
            query.append("请严格按以下纯文本模板输出（不要使用Markdown，不要加多余标题/序号），并结合图片与用户描述给出初步判定：\n\n");
            query.append("判定结果如下：\n\n");
            query.append("植物品种未明确+异常类型：[在这里给出综合结论，包含：症状概述；可能诱因；初步解决方案。]\n\n");
            query.append("判定依据说明：\n\n");
            query.append("症状特征：[一句话说明症状与异常范围/占比（可用大致比例），并说明为什么判定异常或无法确定。]\n");
            query.append("环境诱因：[一句话说明可能的环境/管理诱因，如高湿、通风差、叶面潮湿等。]\n");
            query.append("标准术语：[给出统一术语，如“叶斑病类异常/黄化缺素类异常/病虫害类异常/待进一步确认”等。]\n");
            query.append("解决建议：[给出一段可执行建议，逗号分隔，3-5条要点即可；必须是异常处理/护理措施，不要输出“建议用户如何描述/如何拍照/如何上传”的内容。]\n");
            query.append("如需更具体判定，请补充植物品种及环境描述。\n\n");
            if (userDescription != null && !userDescription.trim().isEmpty()) {
                query.append("用户描述：").append(userDescription.trim()).append("\n");
            }
            requestBody.put("query", query.toString());
            requestBody.put("response_mode", "blocking");
            requestBody.put("user", "sys-user");

            if (fileId != null) {
                JSONObject fileObj = new JSONObject();
                fileObj.put("type", "image");
                fileObj.put("transfer_method", "local_file");
                fileObj.put("upload_file_id", fileId);
                requestBody.put("files", Collections.singletonList(fileObj));
            } else if (imageUrl != null) {
                JSONObject fileObj = new JSONObject();
                fileObj.put("type", "image");
                fileObj.put("transfer_method", "remote_url");
                fileObj.put("url", imageUrl);
                requestBody.put("files", Collections.singletonList(fileObj));
            }

            RequestBody body = RequestBody.create(
                    requestBody.toJSONString(), MediaType.parse("application/json"));

            Request request = new Request.Builder()
                    .url(apiUrl + "/chat-messages")
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .post(body)
                    .build();

            try (Response response = client.newCall(request).execute()) {
                if (!response.isSuccessful()) {
                    log.error("Dify API Error: {}", response.body().string());
                    return "AI分析服务暂时不可用";
                }
                String respStr = response.body().string();
                JSONObject respJson = JSON.parseObject(respStr);
                return respJson.getString("answer");
            }

        } catch (Exception e) {
            log.error("Dify Analysis Failed", e);
            return "AI分析失败: " + e.getMessage();
        }
    }

    public String analyzeImage(String imageUrl, File imageFile) {
        return analyzeImage(imageUrl, imageFile, null);
    }

    private String uploadFile(File file) throws IOException {
        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("file", file.getName(),
                        RequestBody.create(file, MediaType.parse("image/jpeg")))
                .addFormDataPart("user", "sys-user")
                .build();

        Request request = new Request.Builder()
                .url(apiUrl + "/files/upload")
                .header("Authorization", "Bearer " + apiKey)
                .post(requestBody)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Upload failed: " + response.body().string());
            }
            JSONObject json = JSON.parseObject(response.body().string());
            return json.getString("id");
        }
    }
}
