<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">我的异常上报</h1>
      <a-button type="primary" @click="$router.push('/user/abnormality-report')"
        >新增上报</a-button
      >
    </div>

    <!-- Mobile List View -->
    <div class="md:hidden">
      <div
        v-for="record in reports"
        :key="record.id"
        class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
      >
        <div class="flex justify-between items-start mb-2">
          <span class="font-bold text-gray-900">{{
            record.abnormalityType
          }}</span>
          <a-tag :color="getStatusColor(record.status)" class="mr-0 text-xs">
            {{ getStatusLabel(record.status) }}
          </a-tag>
        </div>

        <div class="text-sm text-gray-500 mb-1">
          植物:
          {{
            record.plantId
              ? record.plantName || `未知植物 (ID: ${record.plantId})`
              : `校园任意植物 (${record.location})`
          }}
        </div>
        <div class="text-sm text-gray-500 mb-1">
          时间: {{ record.createdAt }}
        </div>
        <div class="text-sm text-gray-600 mb-2 line-clamp-2">
          描述: {{ record.description }}
        </div>

        <div
          v-if="record.imageUrls"
          class="flex gap-2 mb-3 overflow-x-auto pb-1"
        >
          <a-image
            v-for="(url, index) in parseImages(record.imageUrls)"
            :key="index"
            :src="url"
            :width="60"
            class="object-cover rounded flex-shrink-0"
          />
        </div>

        <div class="mt-2 pt-2 border-t border-gray-100 flex justify-end">
          <a-button size="small" @click="viewDetail(record)">详情</a-button>
        </div>
      </div>

      <!-- Mobile Pagination -->
      <div class="flex justify-center mt-4" v-if="reports.length > 0">
        <a-pagination
          v-model:current="pagination.current"
          :total="pagination.total"
          :pageSize="pagination.pageSize"
          @change="
            (page) =>
              handleTableChange({
                current: page,
                pageSize: pagination.pageSize,
              })
          "
          simple
        />
      </div>
    </div>

    <!-- Desktop Table View -->
    <a-table
      class="hidden md:block"
      :columns="columns"
      :data-source="reports"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      :scroll="{ x: 800 }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'plantName'">
          {{
            record.plantId
              ? record.plantName || `未知植物 (ID: ${record.plantId})`
              : `任意植物 (${record.location})`
          }}
        </template>
        <template v-else-if="column.key === 'status'">
          <a-tag :color="getStatusColor(record.status)">{{
            getStatusLabel(record.status)
          }}</a-tag>
        </template>
        <template v-else-if="column.key === 'imageUrls'">
          <div v-if="record.imageUrls" class="flex gap-1">
            <a-image
              v-for="(url, index) in parseImages(record.imageUrls)"
              :key="index"
              :src="url"
              :width="40"
              class="object-cover rounded"
            />
          </div>
          <span v-else>无图片</span>
        </template>
        <template v-else-if="column.key === 'action'">
          <a @click="viewDetail(record)">详情</a>
        </template>
      </template>
    </a-table>

    <!-- Detail Modal -->
    <a-modal
      v-model:open="detailVisible"
      title="上报详情"
      :footer="null"
      width="600px"
    >
      <div v-if="currentReport">
        <a-descriptions bordered :column="1">
          <a-descriptions-item label="植物" v-if="currentReport.plantId">
            {{ currentReport.plantName }} (ID: {{ currentReport.plantId }})
          </a-descriptions-item>
          <a-descriptions-item label="植物" v-else>
            校园任意植物 (位置: {{ currentReport.location }})
          </a-descriptions-item>
          <a-descriptions-item label="异常类型">{{
            currentReport.abnormalityType
          }}</a-descriptions-item>
          <a-descriptions-item label="当前状态">
            <a-tag :color="getStatusColor(currentReport.status)">{{
              getStatusLabel(currentReport.status)
            }}</a-tag>
          </a-descriptions-item>
          <a-descriptions-item label="上报时间">{{
            currentReport.createdAt
          }}</a-descriptions-item>
          <a-descriptions-item label="异常描述">{{
            currentReport.description
          }}</a-descriptions-item>
          <a-descriptions-item label="现场照片">
            <div v-if="currentReport.imageUrls" class="flex gap-2 flex-wrap">
              <a-image
                v-for="(url, index) in parseImages(currentReport.imageUrls)"
                :key="index"
                :src="url"
                :width="100"
                class="object-cover rounded border"
              />
            </div>
            <span v-else>无</span>
          </a-descriptions-item>
          <a-descriptions-item
            label="AI建议"
            v-if="currentReport.suggestedSolution"
          >
            <div
              class="p-2 bg-blue-50 rounded text-blue-800 whitespace-pre-wrap"
            >
              {{ currentReport.suggestedSolution }}
            </div>
          </a-descriptions-item>
          <a-descriptions-item
            label="处理结果"
            v-if="currentReport.resolutionDescription"
          >
            {{ currentReport.resolutionDescription }}
          </a-descriptions-item>
        </a-descriptions>
      </div>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from "vue";
import { message } from "ant-design-vue";
import { getMyAbnormalities } from "@/api/abnormality";

const parseImages = (jsonStr?: string) => {
  if (!jsonStr) return [];
  try {
    const parsed = JSON.parse(jsonStr);
    if (Array.isArray(parsed)) {
      return parsed.filter(Boolean).map(normalizeImageUrl);
    }
  } catch (e) {}

  return jsonStr
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean)
    .map((s) => s.replace(/^\"|\"$/g, ""))
    .map(normalizeImageUrl);
};

const normalizeImageUrl = (url: string) => {
  if (!url) return url;
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  if (url.startsWith("/api/")) return url;
  if (url.startsWith("/uploads/") || url.startsWith("/profile/")) {
    return `/api${url}`;
  }
  return url;
};

const loading = ref(false);
const reports = ref([]);
const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0,
});
const detailVisible = ref(false);
const currentReport = ref<any>(null);

const columns = [
  { title: "ID", dataIndex: "id", width: 60 },
  { title: "植物", key: "plantName" },
  { title: "异常类型", dataIndex: "abnormalityType", width: 120 },
  { title: "描述", dataIndex: "description", ellipsis: true },
  { title: "照片", key: "imageUrls", width: 150 },
  { title: "状态", key: "status", width: 100 },
  { title: "上报时间", dataIndex: "createdAt", width: 180 },
  { title: "操作", key: "action", width: 80 },
];

const getStatusLabel = (status: string) => {
  const map: any = {
    PENDING: "已上报", // Changed from 待处理 to match the screenshot
    REPORTED: "已上报",
    ASSIGNED: "处理中",
    RESOLVED: "已解决",
    CLOSED: "已关闭",
    UNRESOLVED: "未解决",
  };
  return map[status] || status;
};

const getStatusColor = (status: string) => {
  const map: any = {
    PENDING: "blue", // Changed to blue to match 已上报
    REPORTED: "blue",
    ASSIGNED: "processing",
    RESOLVED: "success",
    CLOSED: "default",
    UNRESOLVED: "error",
  };
  return map[status] || "default";
};

const fetchReports = async () => {
  loading.value = true;
  try {
    const res: any = await getMyAbnormalities({
      page: pagination.value.current,
      size: pagination.value.pageSize,
    });
    reports.value = res.records;
    pagination.value.total = res.total;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  pagination.value.current = pag.current;
  pagination.value.pageSize = pag.pageSize;
  fetchReports();
};

const viewDetail = (record: any) => {
  currentReport.value = record;
  detailVisible.value = true;
};

onMounted(() => {
  fetchReports();
});
</script>
