<template>
  <div class="p-6">
    <div class="mb-4 flex justify-between items-center">
      <h1 class="text-2xl font-bold">内容举报管理</h1>
      <div class="flex gap-4">
        <a-select v-model:value="queryParams.status" @change="handleSearch" class="w-32">
          <a-select-option value="">全部状态</a-select-option>
          <a-select-option value="PENDING">待处理</a-select-option>
          <a-select-option value="RESOLVED">已处理</a-select-option>
          <a-select-option value="REVIEWED">已审核</a-select-option>
        </a-select>
      </div>
    </div>

    <!-- Mobile List View -->
    <div class="md:hidden">
      <div
        v-for="record in reports"
        :key="record.id"
        class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
      >
        <div class="flex justify-between items-start mb-2">
          <span class="font-bold text-gray-900 line-clamp-1">举报帖子: {{ record.postTitle }}</span>
          <a-tag :color="getStatusColor(record.status)" class="mr-0 text-xs">
            {{ getStatusText(record.status) }}
          </a-tag>
        </div>
        
        <div class="text-sm text-gray-500 mb-1">
          举报人: {{ record.reporterName }} | 时间: {{ formatDate(record.createdAt) }}
        </div>
        <div class="text-sm text-gray-700 bg-gray-50 p-2 rounded mb-2">
          原因: {{ record.reason }}
        </div>
        
        <div v-if="record.status === 'PENDING'" class="flex gap-2 pt-2 border-t border-gray-100 justify-end">
          <a-button size="small" @click="viewPost(record.postId)">查看内容</a-button>
          <a-button size="small" type="primary" @click="handleAction(record, 'IGNORE')">忽略</a-button>
          <a-button size="small" danger @click="handleAction(record, 'DELETE_POST')">删除帖子</a-button>
        </div>
        <div v-else class="flex justify-between items-center pt-2 border-t border-gray-100">
          <a-button size="small" @click="viewPost(record.postId)">查看内容</a-button>
          <div class="text-xs text-gray-400 text-right">
            处理人: {{ record.reviewerName }} | {{ formatDate(record.reviewedAt) }}
          </div>
        </div>
      </div>
      
      <!-- Mobile Pagination -->
      <div class="flex justify-center mt-4" v-if="reports.length > 0">
         <a-pagination 
           v-model:current="pagination.current" 
           :total="pagination.total" 
           :pageSize="pagination.pageSize" 
           @change="(page) => handleTableChange({ current: page, pageSize: pagination.pageSize })"
           simple 
         />
      </div>
    </div>

    <!-- Desktop Table View -->
    <a-table
      class="hidden md:block shadow-sm bg-white rounded-lg overflow-hidden"
      :columns="columns"
      :dataSource="reports"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      rowKey="id"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">
            {{ getStatusText(record.status) }}
          </a-tag>
        </template>
        <template v-if="column.key === 'reason'">
          <div class="max-w-xs truncate" :title="record.reason">{{ record.reason }}</div>
        </template>
        <template v-if="column.key === 'action'">
          <div class="flex gap-2 items-center">
            <a-button type="link" size="small" @click="viewPost(record.postId)">查看</a-button>
            <template v-if="record.status === 'PENDING'">
              <a-button type="link" size="small" @click="handleAction(record, 'IGNORE')">忽略</a-button>
              <a-button type="link" size="small" danger @click="handleAction(record, 'DELETE_POST')">删除帖子</a-button>
            </template>
            <div v-else class="text-xs text-gray-400">
              已处理
            </div>
          </div>
        </template>
      </template>
    </a-table>

    <!-- Post Detail Modal -->
    <a-modal
      v-model:open="postDetailVisible"
      title="帖子详情"
      :footer="null"
      width="700px"
    >
      <a-spin :spinning="postLoading">
        <div v-if="currentPost" class="py-4">
          <h2 class="text-2xl font-bold text-gray-900 mb-2">{{ currentPost.title }}</h2>
          <div class="flex items-center gap-4 text-gray-500 text-sm mb-6 pb-4 border-b">
            <span>作者: {{ currentPost.authorName }}</span>
            <span>发布时间: {{ formatDate(currentPost.createdAt) }}</span>
            <a-tag color="blue">{{ currentPost.tag }}</a-tag>
          </div>
          <div class="text-gray-700 whitespace-pre-wrap leading-relaxed min-h-[200px]">
            {{ currentPost.content }}
          </div>
        </div>
        <div v-else-if="!postLoading" class="py-10 text-center text-gray-400">
          该帖子已被删除或无法加载
        </div>
      </a-spin>
    </a-modal>

    <!-- Handle Report Modal -->
    <a-modal
      v-model:open="handleModalVisible"
      :title="handleActionType === 'IGNORE' ? '忽略举报' : '删除违规帖子'"
      @ok="submitHandle"
      :confirmLoading="handleLoading"
    >
      <div class="py-2">
        <div class="mb-2 text-gray-600">
          {{ handleActionType === 'IGNORE' ? '请填写反馈给举报人的原因：' : '请填写删除帖子的原因（将发送给作者）：' }}
        </div>
        <a-textarea
          v-model:value="handleReason"
          :placeholder="handleActionType === 'IGNORE' ? '例如：经核实，该帖子内容符合社区规范。' : '例如：内容包含虚假信息/广告。'"
          :rows="4"
        />
        <div v-if="handleActionType === 'DELETE_POST'" class="mt-2 text-xs text-gray-400">
          通知模板：因 [填写原因]，您的帖子被删除，如有疑问请联系管理员...
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import { getReportList, handleReport } from '@/api/report';
import { getPost } from '@/api/knowledge';
import type { ContentReport } from '@/api/report';
import type { KnowledgePostVO } from '@/api/knowledge';
import dayjs from 'dayjs';

const columns = [
  { title: '被举报帖子', dataIndex: 'postTitle', key: 'postTitle', ellipsis: true },
  { title: '帖子作者', dataIndex: 'postAuthorName', key: 'postAuthorName', width: 120 },
  { title: '举报人', dataIndex: 'reporterName', key: 'reporterName', width: 120 },
  { title: '举报原因', dataIndex: 'reason', key: 'reason' },
  { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
  { title: '举报时间', dataIndex: 'createdAt', key: 'createdAt', width: 180, customRender: ({ text }: { text: string }) => formatDate(text) },
  { title: '操作', key: 'action', width: 220 },
];

const loading = ref(false);
const reports = ref<ContentReport[]>([]);
const queryParams = reactive({
  page: 1,
  size: 10,
  status: 'PENDING'
});

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true
});

const postDetailVisible = ref(false);
const postLoading = ref(false);
const currentPost = ref<KnowledgePostVO | null>(null);

const handleModalVisible = ref(false);
const handleLoading = ref(false);
const handleReason = ref("");
const handleActionType = ref<"IGNORE" | "DELETE_POST">("IGNORE");
const currentReport = ref<ContentReport | null>(null);

const fetchReports = async () => {
  loading.value = true;
  try {
    const res: any = await getReportList(queryParams);
    const pageData = res.records ? res : (res.data || {});
    reports.value = pageData.records || [];
    pagination.total = pageData.total || 0;
  } catch (error) {
    message.error('加载失败');
  } finally {
    loading.value = false;
  }
};

const viewPost = async (postId: number) => {
  postDetailVisible.value = true;
  postLoading.value = true;
  currentPost.value = null;
  try {
    const res: any = await getPost(postId);
    currentPost.value = res;
  } catch (e) {
    message.error('获取帖子详情失败');
  } finally {
    postLoading.value = false;
  }
};

const handleSearch = () => {
  queryParams.page = 1;
  pagination.current = 1;
  fetchReports();
};

const handleTableChange = (pag: any) => {
  queryParams.page = pag.current;
  queryParams.size = pag.pageSize;
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchReports();
};

const handleAction = (report: ContentReport, action: "IGNORE" | "DELETE_POST") => {
  currentReport.value = report;
  handleActionType.value = action;
  handleReason.value = "";
  handleModalVisible.value = true;
};

const submitHandle = async () => {
  if (!currentReport.value) return;
  if (!handleReason.value.trim()) {
    message.warning("请填写处理原因");
    return;
  }

  handleLoading.value = true;
  try {
    await handleReport(currentReport.value.id, handleActionType.value, handleReason.value);
    message.success("处理成功");
    handleModalVisible.value = false;
    fetchReports();
  } catch (e) {
    message.error("操作失败");
  } finally {
    handleLoading.value = false;
  }
};

const getStatusColor = (status: string) => {
  const map: Record<string, string> = {
    'PENDING': 'orange',
    'RESOLVED': 'green',
    'REVIEWED': 'blue'
  };
  return map[status] || 'default';
};

const getStatusText = (status: string) => {
  const map: Record<string, string> = {
    'PENDING': '待处理',
    'RESOLVED': '已处理',
    'REVIEWED': '已审核'
  };
  return map[status] || status;
};

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  return dayjs(dateStr).format('YYYY-MM-DD HH:mm');
};

onMounted(() => {
  fetchReports();
});
</script>
