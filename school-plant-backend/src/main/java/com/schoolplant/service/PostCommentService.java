package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.entity.PostComment;
import java.util.List;

public interface PostCommentService extends IService<PostComment> {
    List<PostComment> getCommentsByPostId(Long postId);
    boolean addComment(PostComment comment);
}
