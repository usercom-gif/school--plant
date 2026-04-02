<template>
  <div>
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 text-lg font-bold">认养申请初审（发布者视角）</div>

      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.id"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <span class="font-bold text-gray-900">申请: {{ record.plantName }}</span>
            <a-tag color="orange" class="mr-0 text-xs">待初审</a-tag>
          </div>
          
          <div class="text-sm text-gray-500 mb-1">
            申请人: {{ record.userName }}
          </div>
          <div class="text-sm text-gray-500 mb-1">
            申请时间: {{ record.createdAt }}
          </div>
          <div class="text-sm text-gray-600 mb-2 line-clamp-2">
            理由: {{ record.careExperience }}
          </div>
          
          <div class="mt-3 pt-3 border-t border-gray-100 flex justify-end gap-2">
            <a-button size="small" type="primary" ghost @click="handleAudit(record, 'PASS')">通过</a-button>
            <a-button size="small" danger @click="handleAudit(record, 'REJECT')">驳回</a-button>
          </div>
        </div>
        
        <!-- Mobile Pagination -->
        <div class="flex justify-center mt-4" v-if="dataSource.length > 0">
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
        class="hidden md:block"
        :columns="columns"
        :data-source="dataSource"
        :loading="loading"
        :pagination="pagination"
        @change="handleTableChange"
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'">
            <a-tag color="orange">待初审</a-tag>
          </template>
          <template v-else-if="column.key === 'action'">
            <a @click="handleAudit(record, 'PASS')">通过</a>
            <a-divider type="vertical" />
            <a class="text-red-500" @click="handleAudit(record, 'REJECT')">驳回</a>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- Audit Modal -->
    <a-modal
      v-model:open="auditModalVisible"
      :title="auditAction === 'PASS' ? '通过申请（初审）' : '驳回申请（初审）'"
      @ok="submitAudit"
      :confirmLoading="auditLoading"
    >
      <a-form layout="vertical">
        <div v-if="auditAction === 'PASS'" class="mb-4 text-gray-500">
          <InfoCircleOutlined /> 初审通过后，申请将提交给管理员进行终审。
        </div>
        <a-form-item :label="auditAction === 'PASS' ? '备注' : '驳回原因'" :required="auditAction === 'REJECT'">
          <a-textarea
            v-model:value="auditComment"
            :rows="4"
            :placeholder="auditAction === 'PASS' ? '请输入备注（选填）' : '请输入驳回原因（必填）'"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from "vue";
import { message } from "ant-design-vue";
import { InfoCircleOutlined } from "@ant-design/icons-vue";
import {
  getInitialAuditList,
  auditApplication,
  type AdoptionApplication,
} from "@/api/adoption";

const loading = ref(false);
const dataSource = ref<AdoptionApplication[]>([]);
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
});

const auditModalVisible = ref(false);
const auditLoading = ref(false);
const currentRecord = ref<AdoptionApplication | null>(null);
const auditAction = ref<"PASS" | "REJECT">("PASS");
const auditComment = ref("");

const columns = [
  { title: "ID", dataIndex: "id", width: 60 },
  { title: "植物名称", dataIndex: "plantName" },
  { title: "申请人", dataIndex: "userName" },
  { title: "申请理由", dataIndex: "careExperience" },
  { title: "申请时间", dataIndex: "createdAt" },
  { title: "状态", key: "status", width: 100 },
  { title: "操作", key: "action", width: 150 },
];

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getInitialAuditList({
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

const handleAudit = (record: AdoptionApplication, action: "PASS" | "REJECT") => {
  currentRecord.value = record;
  auditAction.value = action;
  auditComment.value = "";
  auditModalVisible.value = true;
};

const submitAudit = async () => {
  if (!currentRecord.value) return;

  if (auditAction.value === 'REJECT' && !auditComment.value.trim()) {
    message.error("请输入驳回原因");
    return;
  }

  auditLoading.value = true;
  try {
    await auditApplication({
      id: currentRecord.value.id,
      action: auditAction.value,
      comment: auditComment.value,
    });
    message.success("操作成功");
    auditModalVisible.value = false;
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    auditLoading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>
