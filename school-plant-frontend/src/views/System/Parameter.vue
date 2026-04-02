<template>
  <div class="p-6">
    <a-card title="系统参数配置" :bordered="false">
      <template #extra>
        <a-input-search
          v-model:value="keyword"
          placeholder="搜索参数名或说明"
          style="width: 250px"
          @search="handleSearch"
          :loading="loading"
          allow-clear
        />
      </template>
      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in data"
          :key="record.id"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <span class="font-bold text-gray-900 break-all">{{ record.paramKey }}</span>
            <a @click="handleEdit(record)">编辑</a>
          </div>
          
          <div class="text-sm text-gray-800 mb-1 font-medium break-all">
            值: {{ record.paramValue }}
          </div>
          <div class="text-sm text-gray-500 mb-1">
            说明: {{ record.description }}
          </div>
          <div class="text-xs text-gray-400">
            修改时间: {{ record.updatedAt }}
          </div>
        </div>
      </div>

      <!-- Desktop Table View -->
      <a-table 
        class="hidden md:block"
        :columns="columns" 
        :data-source="data" 
        :loading="loading" 
        row-key="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'action'">
            <a @click="handleEdit(record)">编辑</a>
          </template>
        </template>
      </a-table>
    </a-card>

    <a-modal
      v-model:visible="visible"
      title="修改参数"
      @ok="handleOk"
      ok-text="确定"
      cancel-text="取消"
      :confirmLoading="confirmLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="参数名称">
          <a-input v-model:value="currentParam.paramKey" disabled />
        </a-form-item>
        <a-form-item label="参数说明">
          <a-input v-model:value="currentParam.description" disabled />
        </a-form-item>
        <a-form-item label="参数值" :help="getErrorMsg(currentParam.paramKey)">
           <a-input v-model:value="editValue" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import { getParameterList, updateParameter, type SystemParameter } from '@/api/system-parameter';

const columns = [
  { title: '参数名称', dataIndex: 'paramKey', key: 'paramKey' },
  { title: '参数值', dataIndex: 'paramValue', key: 'paramValue' },
  { title: '说明', dataIndex: 'description', key: 'description' },
  { title: '修改时间', dataIndex: 'updatedAt', key: 'updatedAt' },
  { title: '操作', key: 'action' },
];

const data = ref<SystemParameter[]>([]);
const loading = ref(false);
const keyword = ref('');
const visible = ref(false);
const confirmLoading = ref(false);
const currentParam = ref<Partial<SystemParameter>>({});
const editValue = ref('');

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await getParameterList(keyword.value);
    data.value = res;
  } catch (error) {
    message.error('获取参数列表失败');
  } finally {
    loading.value = false;
  }
};

const handleSearch = () => {
  fetchData();
};

const handleEdit = (record: SystemParameter) => {
  currentParam.value = { ...record };
  editValue.value = record.paramValue;
  visible.value = true;
};

const getErrorMsg = (key?: string) => {
    return '';
}

const handleOk = async () => {
  if (!editValue.value) {
    message.warning('请输入参数值');
    return;
  }
  
  // Basic validation
  if (currentParam.value.paramKey === 'ADOPTION_LIMIT' || 
      currentParam.value.paramKey === 'ABNORMALITY_TIMEOUT_HOURS' ||
      currentParam.value.paramKey === 'KNOWLEDGE_FEATURE_LIKES' ||
      currentParam.value.paramKey === 'TASK_OVERDUE_DAYS' ||
      currentParam.value.paramKey === 'ACHIEVEMENT_COMPLETION_RATE') {
      
      const num = Number(editValue.value);
      if (isNaN(num) || num < 0) {
          message.error('请输入有效的正整数');
          return;
      }
  } else if (currentParam.value.paramKey === 'CURRENT_CYCLE') {
      // Validate cycle format if needed, e.g., YYYY-CycleX
      if (!/^20\d{2}-Cycle[1-2]$/.test(editValue.value)) {
          message.error('格式错误，示例：2024-Cycle1');
          return;
      }
  } else if (currentParam.value.paramKey === 'CLOCK_IN_START_TIME' || 
             currentParam.value.paramKey === 'CLOCK_IN_END_TIME') {
      // Validate time format HH:mm
      if (!/^([01]\d|2[0-3]):[0-5]\d$/.test(editValue.value)) {
          message.error('时间格式错误，示例：13:00');
          return;
      }
  }

  confirmLoading.value = true;
  try {
    await updateParameter(currentParam.value.paramKey!, editValue.value);
    message.success('更新成功');
    visible.value = false;
    fetchData();
  } catch (error) {
    message.error('更新失败');
  } finally {
    confirmLoading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>
