<template>
  <div>
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 text-lg font-bold">我的认养申请记录</div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <span class="font-bold text-gray-900"
              >申请: {{ record.plantName }}</span
            >
            <a-tag :color="getStatusColor(record.status)" class="mr-0 text-xs">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </div>

          <div class="text-sm text-gray-500 mb-1">
            申请时间: {{ record.createdAt }}
          </div>
          <div class="text-sm text-gray-600 mb-2 line-clamp-2">
            理由: {{ record.careExperience }}
          </div>
          <div v-if="record.rejectionReason" class="text-xs text-red-500 mb-2">
            驳回: {{ record.rejectionReason }}
          </div>

          <div
            class="mt-3 pt-3 border-t border-gray-100 flex justify-end gap-2 flex-wrap"
          >
            <a-button size="small" @click="viewDetails(record)">详情</a-button>
            <a-button size="small" @click="viewLogs(record)">日志</a-button>
            <template
              v-if="
                record.status === 'PENDING' || record.status === 'INITIAL_AUDIT'
              "
            >
              <a-button size="small" @click="handleEdit(record)">修改</a-button>
              <a-button size="small" danger @click="handleCancel(record)"
                >撤销</a-button
              >
            </template>
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
        :scroll="{ x: 800 }"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag :color="getStatusColor(record.status)">
              {{ getStatusLabel(record.status) }}
            </a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a @click="viewDetails(record)">详情</a>
            <a-divider type="vertical" />
            <a @click="viewLogs(record)">日志</a>
            <template
              v-if="
                record.status === 'PENDING' || record.status === 'INITIAL_AUDIT'
              "
            >
              <a-divider type="vertical" />
              <a @click="handleEdit(record)">修改</a>
              <a-divider type="vertical" />
              <a class="text-red-500" @click="handleCancel(record)">撤销</a>
            </template>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Details Modal -->
    <a-modal v-model:open="detailsModalVisible" title="申请详情" :footer="null">
      <a-descriptions bordered :column="1">
        <a-descriptions-item label="申请植物">{{
          currentDetailRecord?.plantName
        }}</a-descriptions-item>
        <a-descriptions-item label="认养周期"
          >{{
            currentDetailRecord?.adoptionPeriodMonths
          }}
          个月</a-descriptions-item
        >
        <a-descriptions-item label="申请时间">{{
          currentDetailRecord?.createdAt
        }}</a-descriptions-item>
        <a-descriptions-item label="当前状态">
          <a-tag :color="getStatusColor(currentDetailRecord?.status || '')">
            {{ getStatusLabel(currentDetailRecord?.status || "") }}
          </a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="申请理由">
          <div class="whitespace-pre-wrap">
            {{ currentDetailRecord?.careExperience }}
          </div>
        </a-descriptions-item>
        <a-descriptions-item
          label="驳回原因"
          v-if="currentDetailRecord?.status === 'REJECTED'"
        >
          <div class="text-red-500">
            {{ currentDetailRecord?.rejectionReason }}
          </div>
        </a-descriptions-item>
      </a-descriptions>
    </a-modal>

    <!-- Logs Modal -->
    <a-modal v-model:open="logsVisible" title="审核日志" :footer="null">
      <a-timeline>
        <a-timeline-item
          v-for="log in logs"
          :key="log.id"
          :color="
            getAuditLogColor(log)
          "
        >
          <p class="mb-1 font-bold">
            {{ getAuditLogLabel(log) }}
          </p>
          <p class="mb-1 text-gray-500">{{ log.createdAt }}</p>
          <p v-if="log.comment">{{ log.comment }}</p>
        </a-timeline-item>
        <a-timeline-item v-if="logs.length === 0" color="gray"
          >暂无审核记录</a-timeline-item
        >
      </a-timeline>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { Modal, message } from "ant-design-vue"; // Added Modal import
import {
  getMyApplications, // Fixed import name
  submitApplication,
  cancelApplication,
  updateApplication,
  getAuditLogs,
  type AdoptionApplication,
  type AdoptionAuditLog,
  type AdoptionApplyRequest,
} from "@/api/adoption";

// --- Edit Modal State ---
const editModalVisible = ref(false);
const editLoading = ref(false);
const editFormRef = ref();
const editFormState = reactive<AdoptionApplyRequest>({
  id: undefined,
  plantId: 0,
  adoptionPeriodMonths: 6,
  contactPhone: "",
  careExperience: "",
});

const handleEdit = (record: AdoptionApplication) => {
  editFormState.id = record.id;
  editFormState.plantId = record.plantId;
  editFormState.adoptionPeriodMonths = record.adoptionPeriodMonths;
  editFormState.contactPhone = (record as any).contactPhone || "";
  editFormState.careExperience = record.careExperience;
  editModalVisible.value = true;
};

const submitEdit = async () => {
  try {
    await editFormRef.value.validate();
    editLoading.value = true;
    await updateApplication(editFormState);
    message.success("修改成功");
    editModalVisible.value = false;
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    editLoading.value = false;
  }
};

const loading = ref(false);
const dataSource = ref<AdoptionApplication[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const logsVisible = ref(false);
const logs = ref<AdoptionAuditLog[]>([]);

// --- Details Modal State ---
const detailsModalVisible = ref(false);
const currentDetailRecord = ref<AdoptionApplication | null>(null);

const columns = [
  { title: "ID", dataIndex: "id", width: 60 },
  { title: "植物名称", dataIndex: "plantName" },
  { title: "申请理由", dataIndex: "careExperience" },
  { title: "驳回原因", dataIndex: "rejectionReason" },
  { title: "状态", key: "status", dataIndex: "status", width: 100 },
  { title: "申请时间", dataIndex: "createdAt" },
  { title: "操作", key: "action", width: 150 },
];

const getStatusColor = (status: string) => {
  const s = (status || "").trim().toUpperCase();
  const map: any = {
    INITIAL_AUDIT: "orange", // Same as pending
    PENDING: "orange",
    APPROVED: "green",
    REJECTED: "red",
    INITIAL_PASSED: "cyan",
    REVIEW_PASSED: "blue",
    CANCELLED: "default",
  };
  return map[s] || "default";
};

const getStatusLabel = (status: string) => {
  const s = (status || "").trim().toUpperCase();
  const map: any = {
    INITIAL_AUDIT: "发布者初审",
    PENDING: "管理员审核",
    APPROVED: "审核通过",
    REJECTED: "审核驳回",
    INITIAL_PASSED: "初审通过",
    REVIEW_PASSED: "复审通过",
    CANCELLED: "已取消",
  };
  return map[s] || status;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getMyApplications({
      page: pagination.current,
      size: pagination.pageSize,
    });
    dataSource.value = res.records;
    pagination.total = res.total;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag: any) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchData();
};

const getAuditLogAction = (log: AdoptionAuditLog) => {
  const action = (log.auditAction || (log as any).action || "").toString().trim().toUpperCase();
  if (action === "PASS" || action === "APPROVED" || action === "INITIAL_PASS" || action === "INITIAL_PASSED") {
    return "PASS";
  }
  if (action === "REJECT" || action === "REJECTED") {
    return "REJECT";
  }
  return action;
};

const getAuditLogStage = (log: AdoptionAuditLog) => {
  const stage = (log.auditStage || "").toString().trim().toUpperCase();
  if (stage) return stage;
  const raw = (log.auditAction || (log as any).action || "").toString().trim().toUpperCase();
  if (raw === "INITIAL_PASS" || raw === "INITIAL_PASSED") return "INITIAL";
  return "REVIEW";
};

const getAuditLogLabel = (log: AdoptionAuditLog) => {
  const action = getAuditLogAction(log);
  const stage = getAuditLogStage(log);

  const stageLabel = stage === "INITIAL" ? "初审" : stage === "REVIEW" ? "复审" : "审核";
  if (action === "PASS") return `${stageLabel}通过`;
  if (action === "REJECT") return `${stageLabel}驳回`;
  return `${stageLabel}记录`;
};

const getAuditLogColor = (log: AdoptionAuditLog) => {
  const action = getAuditLogAction(log);
  if (action === "REJECT") return "red";
  if (action === "PASS") return "green";
  return "gray";
};

const handleCancel = (record: AdoptionApplication) => {
  Modal.confirm({
    title: "确认撤销",
    content: "确定要撤销这条认养申请吗？撤销后无法恢复。",
    onOk: async () => {
      try {
        await cancelApplication(record.id);
        message.success("撤销成功");
        fetchData();
      } catch (e) {
        console.error(e);
      }
    },
  });
};

const viewDetails = (record: AdoptionApplication) => {
  currentDetailRecord.value = record;
  detailsModalVisible.value = true;
};

const viewLogs = async (record: AdoptionApplication) => {
  try {
    const res = await getAuditLogs(record.id);
    logs.value = res;
    logsVisible.value = true;
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
