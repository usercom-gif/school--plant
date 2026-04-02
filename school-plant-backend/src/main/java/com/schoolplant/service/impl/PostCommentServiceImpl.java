package com.schoolplant.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.schoolplant.entity.PostComment;
import com.schoolplant.mapper.PostCommentMapper;
import com.schoolplant.service.PostCommentService;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PostCommentServiceImpl extends ServiceImpl<PostCommentMapper, PostComment> implements PostCommentService {

    @Override
    public List<PostComment> getCommentsByPostId(Long postId) {
        return baseMapper.listByPostId(postId);
    }

    @Override
    public boolean addComment(PostComment comment) {
        return save(comment);
    }
}
