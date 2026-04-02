package com.schoolplant.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.schoolplant.dto.ContentReportQueryRequest;
import com.schoolplant.entity.ContentReport;
import com.schoolplant.vo.ContentReportVO;

public interface ContentReportService extends IService<ContentReport> {
    Page<ContentReportVO> getReportList(ContentReportQueryRequest request);
    void handleReport(Long id, String action, String reason); // action: IGNORE, DELETE_POST
}
