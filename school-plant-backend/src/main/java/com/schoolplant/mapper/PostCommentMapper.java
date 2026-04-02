package com.schoolplant.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.schoolplant.entity.PostComment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PostCommentMapper extends BaseMapper<PostComment> {
    
    @Select("SELECT pc.*, u.username, u.avatar_url, u.real_name, " +
            "pu.username AS parentUsername, pu.real_name AS parentRealName, pu.avatar_url AS parentAvatarUrl " +
            "FROM post_comments pc " +
            "JOIN users u ON pc.user_id = u.id " +
            "LEFT JOIN post_comments ppc ON pc.parent_id = ppc.id " +
            "LEFT JOIN users pu ON ppc.user_id = pu.id " +
            "WHERE pc.post_id = #{postId} " +
            "ORDER BY pc.created_at ASC")
    List<PostComment> listByPostId(@Param("postId") Long postId);
}
