package com.schoolplant.controller;

import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.stp.StpUtil;
import com.schoolplant.annotation.Log;
import com.schoolplant.common.R;
import com.schoolplant.entity.PostComment;
import com.schoolplant.service.PostCommentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "帖子评论管理", description = "帖子评论管理")
@RestController
@RequestMapping("/knowledge/comment")
public class PostCommentController {

    @Autowired
    private PostCommentService commentService;

    @Operation(summary = "获取帖子评论列表")
    @GetMapping("/list/{postId}")
    public R<List<PostComment>> list(@PathVariable Long postId) {
        return R.ok(commentService.getCommentsByPostId(postId));
    }

    @Operation(summary = "发布评论")
    @SaCheckLogin
    @Log(module = "KNOWLEDGE", desc = "发布帖子评论", type = "INSERT", key = "#comment.postId")
    @PostMapping
    public R<Void> add(@RequestBody PostComment comment) {
        comment.setUserId(StpUtil.getLoginIdAsLong());
        commentService.addComment(comment);
        return R.ok();
    }

    @Operation(summary = "删除评论")
    @SaCheckLogin
    @Log(module = "KNOWLEDGE", desc = "删除帖子评论", type = "DELETE", key = "#id")
    @DeleteMapping("/{id}")
    public R<Void> remove(@PathVariable Long id) {
        PostComment comment = commentService.getById(id);
        if (comment == null) {
            return R.fail("评论不存在");
        }
        // 权限校验：作者或管理员
        if (!comment.getUserId().equals(StpUtil.getLoginIdAsLong()) && !StpUtil.hasRole("ADMIN")) {
            return R.fail("无权删除");
        }
        commentService.removeById(id);
        return R.ok();
    }
}
