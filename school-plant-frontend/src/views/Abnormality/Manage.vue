<template>
  <div>
    <!-- Filter -->
    <a-card class="mb-4 shadow-sm" :bordered="false">
      <a-form layout="vertical" :model="queryParams" @finish="fetchData">
        <a-row :gutter="[16, 16]">
          <a-col :xs="24" :sm="12" :md="8" :lg="6">
            <a-form-item label="状态" class="mb-0">
              <a-select
                v-model:value="queryParams.status"
                placeholder="全部状态"
                allow-clear
                class="w-full"
              >
                <a-select-option value="PENDING">已上报</a-select-option>
                <a-select-option value="ASSIGNED">处理中</a-select-option>
                <a-select-option value="RESOLVED">已解决</a-select-option>
                <a-select-option value="UNRESOLVED">未解决</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="12" :md="8" :lg="6">
            <a-form-item label="类型" class="mb-0">
              <a-input
                v-model:value="queryParams.type"
                placeholder="异常类型"
                allow-clear
              />
            </a-form-item>
          </a-col>
          <a-col :xs="24" :sm="24" :md="8" :lg="12">
            <a-form-item label="描述" class="mb-0">
              <a-input
                v-model:value="queryParams.description"
                placeholder="关键词搜索"
                allow-clear
              />
            </a-form-item>
          </a-col>
          <a-col :span="24" class="text-right">
            <a-space>
              <a-button type="primary" html-type="submit" :loading="loading"
                >查询</a-button
              >
              <a-button
                v-if="role === 'USER'"
                type="primary"
                ghost
                @click="router.push('/user/report-abnormality')"
                >上报异常</a-button
              >
            </a-space>
          </a-col>
        </a-row>
      </a-form>
    </a-card>

    <!-- Table -->
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 text-lg font-bold">异常工单管理</div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-4 rounded-xl border border-gray-100 shadow-md"
        >
          <div class="flex justify-between items-start mb-3">
            <div class="flex items-center gap-2">
              <span class="font-bold text-lg text-gray-900">{{
                record.abnormalityType
              }}</span>
              <span class="text-xs text-gray-400">#{{ record.id }}</span>
            </div>
            <a-tag
              :color="getStatusColor(record.status)"
              class="mr-0 px-3 rounded-full"
            >
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </div>

          <div class="space-y-2 mb-4">
            <div class="text-xs text-gray-500 flex items-center">
              <ClockCircleOutlined class="mr-2" />
              {{ record.createdAt }}
            </div>
            <div
              class="text-sm text-gray-700 bg-gray-50 p-3 rounded-lg border border-dashed border-gray-200"
            >
              <div class="text-xs text-gray-400 mb-1">异常描述</div>
              <div class="line-clamp-3">{{ record.description }}</div>
            </div>
            <div
              v-if="record.suggestedSolution"
              class="text-xs text-blue-600 bg-blue-50 p-3 rounded-lg border border-blue-100"
            >
              <div class="font-bold mb-1 flex items-center">
                <RobotOutlined class="mr-1" /> AI 诊断建议
              </div>
              {{ record.suggestedSolution }}
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-2 border-t border-gray-100">
            <a-button
              size="middle"
              class="rounded-lg px-4"
              @click="viewDetail(record)"
            >
              <template #icon><EyeOutlined /></template>
              详情
            </a-button>
            <a-button
              v-if="role === 'ADMIN' && record.status === 'PENDING'"
              size="middle"
              type="primary"
              ghost
              class="rounded-lg px-4"
              @click="openAssign(record)"
            >
              <template #icon><UserAddOutlined /></template>
              分派
            </a-button>
            <a-button
              v-if="role === 'MAINTAINER' && record.status === 'ASSIGNED'"
              size="middle"
              type="primary"
              ghost
              class="rounded-lg px-4"
              @click="openResolve(record)"
            >
              <template #icon><CheckOutlined /></template>
              处理
            </a-button>
          </div>
        </div>

        <!-- Mobile Pagination -->
        <div class="flex justify-center mt-4" v-if="dataSource.length > 0">
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
        :data-source="dataSource"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
        :scroll="{ x: 1000 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'plantInfo'">
            <span v-if="record.plantId">{{
              record.plantName || "未知植物"
            }}</span>
            <span v-else class="text-gray-500"
              >任意植物 ({{ record.location }})</span
            >
          </template>
          <template v-else-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a @click="viewDetail(record)">详情</a>

              <!-- Admin Actions -->
              <a
                v-if="role === 'ADMIN' && record.status === 'PENDING'"
                @click="openAssign(record)"
                >分派</a
              >

              <!-- Maintainer Actions -->
              <a
                v-if="role === 'MAINTAINER' && record.status === 'ASSIGNED'"
                @click="openResolve(record)"
                >处理</a
              >
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Detail Modal -->
    <a-modal
      v-model:open="detailVisible"
      title="异常详情"
      :footer="null"
      width="700px"
    >
      <a-descriptions bordered :column="1" v-if="currentRecord">
        <a-descriptions-item label="上报人">
          {{ currentRecord.reporterName || "未知" }}
        </a-descriptions-item>
        <a-descriptions-item label="联系电话">
          {{ currentRecord.reporterContact || "暂无" }}
        </a-descriptions-item>
        <a-descriptions-item label="植物" v-if="currentRecord.plantId">
          {{ currentRecord.plantName || "未知植物" }} (ID:
          {{ currentRecord.plantId }})
        </a-descriptions-item>
        <a-descriptions-item label="植物位置" v-else>
          校园任意植物 (位置: {{ currentRecord.location }})
        </a-descriptions-item>
        <a-descriptions-item label="异常类型">{{
          currentRecord.abnormalityType
        }}</a-descriptions-item>
        <a-descriptions-item label="描述">{{
          currentRecord.description
        }}</a-descriptions-item>
        <a-descriptions-item label="AI建议">
          <div
            class="bg-gray-50 p-2 rounded text-gray-600 text-sm whitespace-pre-wrap"
          >
            {{ currentRecord.suggestedSolution }}
          </div>
        </a-descriptions-item>
        <a-descriptions-item label="现场图片">
          <div class="flex gap-2 flex-wrap">
            <a-image
              v-for="(url, idx) in parseImages(currentRecord.imageUrls)"
              :key="idx"
              :src="url"
              :width="100"
            />
          </div>
        </a-descriptions-item>

        <template v-if="currentRecord.status === 'RESOLVED'">
          <a-descriptions-item label="处理结果">{{
            currentRecord.resolutionDescription
          }}</a-descriptions-item>
          <a-descriptions-item label="使用材料">{{
            currentRecord.materialsUsed
          }}</a-descriptions-item>
          <a-descriptions-item label="效果评估">{{
            currentRecord.effectEvaluation
          }}</a-descriptions-item>
          <a-descriptions-item label="处理后图片">
            <div class="flex gap-2 flex-wrap">
              <a-image
                v-for="(url, idx) in parseImages(
                  currentRecord.resolutionImageUrls,
                )"
                :key="idx"
                :src="url"
                :width="100"
              />
            </div>
          </a-descriptions-item>
        </template>
      </a-descriptions>
    </a-modal>

    <!-- Assign Modal (Admin) -->
    <a-modal
      v-model:open="assignVisible"
      title="分派工单"
      @ok="submitAssign"
      :confirmLoading="actionLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="选择养护员" required>
          <a-select
            v-model:value="assignMaintainerId"
            placeholder="请选择养护员"
            :options="maintainers"
            show-search
            option-filter-prop="label"
            class="w-full"
          />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Resolve Modal (Maintainer) -->
    <a-modal
      v-model:open="resolveVisible"
      title="填写处理结果"
      @ok="submitResolve"
      :confirmLoading="actionLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="处理结果" required>
          <a-radio-group v-model:value="resolveForm.result">
            <a-radio value="RESOLVED">处理成功</a-radio>
            <a-radio value="UNRESOLVED">处理失败</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item label="处理措施" required>
          <a-textarea v-model:value="resolveForm.resolution" :rows="3" />
        </a-form-item>
        <a-form-item label="使用材料" required>
          <a-input v-model:value="resolveForm.materials" />
        </a-form-item>
        <a-form-item label="效果评估" required>
          <a-input v-model:value="resolveForm.evaluation" />
        </a-form-item>
        <a-form-item label="处理后照片">
          <input
            type="file"
            accept="image/*"
            @change="handleResolveFileChange"
          />
          <div class="text-xs text-gray-500 mt-1">仅支持上传1张照片。</div>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import {
  ClockCircleOutlined,
  RobotOutlined,
  EyeOutlined,
  UserAddOutlined,
  CheckOutlined,
} from "@ant-design/icons-vue";
import { ref, reactive, onMounted, onUnmounted } from "vue";
import { message } from "ant-design-vue";
import { useRouter } from "vue-router"; // Add router
import {
  getAbnormalityList,
  assignAbnormality,
  resolveAbnormality,
  markAbnormalityUnresolved,
  type PlantAbnormality,
} from "@/api/abnormality";
import { getUsersByRole } from "@/api/user";

const router = useRouter(); // Init router
const role = localStorage.getItem("role") || "USER";
const userId = localStorage.getItem("userId");
const loading = ref(false);
const dataSource = ref<PlantAbnormality[]>([]);
const pagination = reactive({ current: 1, pageSize: 10, total: 0 });
const queryParams = reactive({
  status: undefined,
  type: undefined,
  description: undefined,
});

// Modals
const detailVisible = ref(false);
const assignVisible = ref(false);
const resolveVisible = ref(false);
const actionLoading = ref(false);
const currentRecord = ref<PlantAbnormality | null>(null);

// Assign Form
const assignMaintainerId = ref<number | undefined>(undefined);
const maintainers = ref<any[]>([]);

// Resolve Form
const resolveForm = reactive({
  result: "RESOLVED",
  resolution: "",
  materials: "",
  evaluation: "",
  images: [] as File[],
});

// WebSocket
let socket: WebSocket | null = null;

const columns = [
  { title: "ID", dataIndex: "id", width: 60, fixed: "left" },
  { title: "植物", key: "plantInfo", width: 120 },
  { title: "类型", dataIndex: "abnormalityType", width: 120 },
  { title: "描述", dataIndex: "description", minWidth: 200, ellipsis: true },
  {
    title: "AI建议",
    dataIndex: "suggestedSolution",
    minWidth: 200,
    ellipsis: true,
  },
  { title: "状态", key: "status", width: 100 },
  { title: "上报时间", dataIndex: "createdAt", width: 180 },
  { title: "操作", key: "action", width: 150, fixed: "right" },
];

const getStatusColor = (status: string) => {
  const map: any = {
    PENDING: "blue", // Changed to blue to match 已上报
    ASSIGNED: "orange",
    RESOLVED: "green",
    REPORTED: "blue",
    UNRESOLVED: "red",
  };
  return map[status] || "default";
};

const getStatusLabel = (status: string) => {
  const map: any = {
    PENDING: "已上报", // Changed from 待分派
    ASSIGNED: "处理中",
    RESOLVED: "已解决",
    REPORTED: "已上报", // Keep for backward compatibility with dirty data
    UNRESOLVED: "未解决",
  };
  return map[status] || status;
};

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

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getAbnormalityList({
      page: pagination.current,
      size: pagination.pageSize,
      ...queryParams,
    });
    dataSource.value = res.records;
    pagination.total = res.total;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const viewDetail = (record: PlantAbnormality) => {
  currentRecord.value = record;
  detailVisible.value = true;
};

const openAssign = async (record: PlantAbnormality) => {
  currentRecord.value = record;
  assignMaintainerId.value = undefined;
  assignVisible.value = true;

  // Load maintainers if not loaded
  if (maintainers.value.length === 0) {
    try {
      const res = await getUsersByRole("MAINTAINER");
      maintainers.value = res.map((u: any) => ({
        label: `${u.realName || u.username} (ID: ${u.id})`,
        value: u.id,
      }));
    } catch (e) {
      console.error(e);
    }
  }
};

const submitAssign = async () => {
  if (!currentRecord.value || !assignMaintainerId.value) return;
  actionLoading.value = true;
  try {
    await assignAbnormality(currentRecord.value.id, assignMaintainerId.value);
    message.success("分派成功");
    assignVisible.value = false;
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    actionLoading.value = false;
  }
};

const openResolve = (record: PlantAbnormality) => {
  currentRecord.value = record;
  resolveForm.result = "RESOLVED";
  resolveForm.resolution = "";
  resolveForm.materials = "";
  resolveForm.evaluation = "";
  resolveForm.images = [];
  resolveVisible.value = true;
};

const handleResolveFileChange = (e: Event) => {
  const target = e.target as HTMLInputElement;
  if (target.files) {
    resolveForm.images = Array.from(target.files).slice(0, 1);
  }
};

const submitResolve = async () => {
  if (!currentRecord.value) return;
  actionLoading.value = true;
  try {
    if (resolveForm.result === "UNRESOLVED") {
      await markAbnormalityUnresolved({
        id: currentRecord.value.id,
        reason: resolveForm.resolution,
        materials: resolveForm.materials,
        evaluation: resolveForm.evaluation,
        images: resolveForm.images,
      });
      message.success("已标记为未解决");
    } else {
      await resolveAbnormality({
        id: currentRecord.value.id,
        resolution: resolveForm.resolution,
        materials: resolveForm.materials,
        evaluation: resolveForm.evaluation,
        images: resolveForm.images,
      });
      message.success("处理完成");
    }
    resolveVisible.value = false;
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    actionLoading.value = false;
  }
};

const initWebSocket = () => {
  if (!userId) return;
  // Use generic userId path, backend handles routing
  const protocol = window.location.protocol === "https:" ? "wss" : "ws";
  socket = new WebSocket(
    `${protocol}://localhost:8080/ws/abnormality/${userId}`,
  );

  socket.onmessage = (event) => {
    message.info(event.data); // Show notification
    fetchData(); // Refresh list on update
  };
};

onMounted(() => {
  fetchData();
  initWebSocket();
});

onUnmounted(() => {
  if (socket) socket.close();
});
</script>
