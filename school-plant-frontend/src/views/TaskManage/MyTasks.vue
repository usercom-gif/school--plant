<template>
  <div>
    <a-card class="shadow-sm" :bordered="false">
      <div class="mb-4 flex justify-between items-center">
        <div class="text-lg font-bold">我的养护打卡</div>
        <a-button type="primary" ghost @click="openSettings">
          <template #icon><SettingOutlined /></template>
          设置打卡计划
        </a-button>
      </div>

      <a-list
        :grid="{ gutter: 16, xs: 1, sm: 2, md: 3, lg: 3, xl: 4 }"
        :data-source="dataSource"
      >
        <template #renderItem="{ item }">
          <a-list-item>
            <a-card
              :title="item.taskType"
              hoverable
              class="h-full flex flex-col"
            >
              <template #extra>
                <a-tag :color="getStatusColor(item.status)">{{
                  getStatusLabel(item.status)
                }}</a-tag>
              </template>

              <div class="flex-1">
                <p class="text-gray-500 text-sm mb-2">
                  植物:
                  <span class="text-gray-800 font-medium">{{
                    item.plantName
                  }}</span>
                </p>
                <p class="text-gray-600 mb-4">{{ item.taskDescription }}</p>
                <div class="text-xs text-gray-400 flex items-center gap-1">
                  <ClockCircleOutlined /> 截止: {{ item.dueDate }}
                </div>
              </div>

              <div class="mt-4 pt-4 border-t border-gray-100 flex justify-end">
                <a-button
                  v-if="item.status === 'PENDING'"
                  type="primary"
                  size="small"
                  @click="handleComplete(item)"
                >
                  打卡完成
                </a-button>
                <span v-else class="text-xs text-gray-400">
                  完成于 {{ item.completedDate || "-" }}
                </span>
              </div>
            </a-card>
          </a-list-item>
        </template>
      </a-list>

      <div class="mt-4 flex justify-center" v-if="pagination.total > 0">
        <a-pagination
          v-model:current="pagination.current"
          v-model:pageSize="pagination.pageSize"
          :total="pagination.total"
          @change="fetchData"
        />
      </div>
    </a-card>

    <!-- Complete Modal -->
    <a-modal
      v-model:open="completeModalVisible"
      title="任务打卡"
      @ok="submitComplete"
      :confirmLoading="completeLoading"
    >
      <a-form layout="vertical">
        <a-form-item label="是否有异常情况">
          <a-switch
            v-model:checked="hasAbnormality"
            checked-children="有异常"
            un-checked-children="正常"
          />
        </a-form-item>

        <template v-if="hasAbnormality">
          <a-form-item label="异常类型" required>
            <a-select
              v-model:value="abnormalityForm.type"
              placeholder="请选择异常类型"
            >
              <a-select-option value="PEST">病虫害</a-select-option>
              <a-select-option value="WITHER">枯萎</a-select-option>
              <a-select-option value="DAMAGE">人为损坏</a-select-option>
              <a-select-option value="OTHER">其他</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="异常描述" required>
            <a-textarea
              v-model:value="abnormalityForm.desc"
              placeholder="请详细描述异常情况"
              :rows="3"
            />
          </a-form-item>
        </template>

        <a-form-item label="上传照片凭证" required>
          <a-upload
            v-model:file-list="completeFileList"
            name="file"
            action="/api/common/upload"
            list-type="picture-card"
            accept="image/*"
            :multiple="true"
            :max-count="5"
            :headers="uploadHeaders"
            @change="handleCompleteUploadChange"
          >
            <div v-if="completeFileList.length < 5">
              <div class="mt-1">上传</div>
            </div>
          </a-upload>
          <div class="mt-2 text-xs text-gray-400">最多上传5张照片</div>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Settings Modal -->
    <a-modal
      v-model:open="settingsModalVisible"
      title="养护打卡计划设置"
      @ok="saveSettings"
      :confirmLoading="settingsLoading"
      width="600px"
    >
      <a-form layout="vertical">
        <a-form-item label="选择植物" v-if="activePlants.length > 1">
          <a-select v-model:value="selectedPlantId" @change="handlePlantChange">
            <a-select-option
              v-for="p in activePlants"
              :key="p.plantId"
              :value="p.plantId"
            >
              {{ p.plantName }}
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="计划模式">
          <a-radio-group v-model:value="useCustomPlan">
            <a-radio :value="false">跟随系统默认</a-radio>
            <a-radio :value="true">自定义计划</a-radio>
          </a-radio-group>
          <div class="mt-2 text-xs text-gray-500" v-if="!useCustomPlan">
            系统将根据植物特性自动生成科学的养护任务。
          </div>
        </a-form-item>

        <div v-if="useCustomPlan" class="bg-gray-50 p-4 rounded-md">
          <div class="mb-4 text-sm text-orange-500">
            <InfoCircleOutlined />
            注意：自定义任务的总频率不得低于系统默认要求。打卡时间统一为当天的
            00:00:00 到 23:59:59。
          </div>

          <div
            v-for="(item, index) in settingsForm"
            :key="index"
            class="mb-4 p-3 bg-white rounded border border-gray-200"
          >
            <div class="flex justify-between items-center mb-2">
              <!-- Allow editing task name -->
              <a-input
                v-model:value="item.taskType"
                placeholder="任务名称"
                class="w-32 font-bold border-none shadow-none p-0 focus:shadow-none"
                :bordered="false"
              />
              <span class="text-xs text-gray-400"
                >系统建议：每
                {{ index === 0 ? 3 : index === 1 ? 14 : 7 }} 天</span
              >
            </div>
            <div class="flex items-center gap-2">
              <span>每</span>
              <a-input-number
                v-model:value="item.frequencyDays"
                :min="1"
                :max="30"
                size="small"
              />
              <span>天一次</span>
            </div>
          </div>

          <a-button
            type="dashed"
            block
            size="small"
            @click="
              settingsForm.push({
                taskType: '新任务',
                frequencyDays: 7,
                scheduledTime: '13:00:00',
              })
            "
          >
            + 添加其他任务类型
          </a-button>
        </div>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed } from "vue";
import {
  ClockCircleOutlined,
  SettingOutlined,
  InfoCircleOutlined,
} from "@ant-design/icons-vue";
import { message } from "ant-design-vue";
import type { UploadChangeParam, UploadFile } from "ant-design-vue";
import {
  getMyTasks,
  completeTask,
  reportAbnormalityFromTask,
  getTaskSettings,
  saveTaskSettings,
  type CareTask,
  type UserTaskSettingRequest,
} from "@/api/task";
import { getMyApplications } from "@/api/adoption"; // Fixed import name
import dayjs from "dayjs";

const loading = ref(false);
const dataSource = ref<CareTask[]>([]);
// ... existing state ...

// Settings Modal
const settingsModalVisible = ref(false);
const settingsLoading = ref(false);
const activePlants = ref<any[]>([]);
const selectedPlantId = ref<number | null>(null);
const useCustomPlan = ref(false);
const settingsForm = ref<UserTaskSettingRequest[]>([]);
const systemDefaults = ref<any[]>([]); // To store defaults for validation/comparison

const hasAbnormality = ref(false);
const abnormalityForm = reactive({
  type: undefined,
  desc: "",
});

// ... existing code ...

const openSettings = async () => {
  // 1. Fetch active plants
  try {
    // We reuse getMyApplications but need to filter for APPROVED status
    const res: any = await getMyApplications({ page: 1, size: 100 });
    activePlants.value = res.records.filter(
      (p: any) => p.status === "APPROVED" || p.status === "ADOPTED",
    ); // Check status value

    if (activePlants.value.length === 0) {
      message.warning("您当前没有生效的认养记录");
      return;
    }

    // Default select first one
    selectedPlantId.value = activePlants.value[0].plantId;
    handlePlantChange();
    settingsModalVisible.value = true;
  } catch (e) {
    console.error(e);
  }
};

const handlePlantChange = async () => {
  if (!selectedPlantId.value) return;
  settingsLoading.value = true;
  try {
    // Fetch existing settings
    const res = await getTaskSettings(selectedPlantId.value);
    if (res && res.length > 0) {
      useCustomPlan.value = true;
      settingsForm.value = res.map((s) => ({
        taskType: s.taskType,
        frequencyDays: s.frequencyDays,
        scheduledTime: s.scheduledTime || "13:00:00",
      }));
    } else {
      useCustomPlan.value = false;
      // Fetch defaults?
      // Actually backend `getSettings` returns empty if no custom settings.
      // We need a way to know system defaults to show them or initialize form.
      // For now, let's hardcode some common types or try to infer.
      // Ideally backend should provide "getDefaults".
      // Let's manually add some default types for user to fill if they switch to custom.
      settingsForm.value = [
        { taskType: "浇水", frequencyDays: 3, scheduledTime: "13:00:00" },
        { taskType: "施肥", frequencyDays: 14, scheduledTime: "13:00:00" },
        { taskType: "松土", frequencyDays: 7, scheduledTime: "13:00:00" },
      ];
    }
  } catch (e) {
    console.error(e);
  } finally {
    settingsLoading.value = false;
  }
};

const saveSettings = async () => {
  if (!selectedPlantId.value) return;
  if (!useCustomPlan.value) {
    // If switching back to default, maybe send empty list?
    // Backend: empty list -> delete custom settings -> revert to default.
    // Yes, backend logic supports this.
  }

  settingsLoading.value = true;
  try {
    await saveTaskSettings(
      selectedPlantId.value,
      useCustomPlan.value ? settingsForm.value : [],
    );
    message.success("设置保存成功，次日生效");
    settingsModalVisible.value = false;
  } catch (e: any) {
    console.error(e);
    // Backend throws error if validation fails
    message.error(e.response?.data?.msg || e.message || '保存失败');
  } finally {
    settingsLoading.value = false;
  }
};

// ... existing code ...
const pagination = reactive({
  current: 1,
  pageSize: 12,
  total: 0,
});

// Modal
const completeModalVisible = ref(false);
const completeLoading = ref(false);
const currentTask = ref<CareTask | null>(null);
const completeFileList = ref<UploadFile[]>([]);

const token = localStorage.getItem("token");
const uploadHeaders = token ? { satoken: token } : {};

const handleCompleteUploadChange = (info: UploadChangeParam) => {
  if (info.fileList.length > 5) {
    message.warning("最多上传5张照片");
  }
  completeFileList.value = info.fileList.slice(0, 5);

  if (info.file.status === "done") {
    const response = (info.file as any).response;
    if (!response || response.code !== 200) {
      message.error(response?.msg || "上传失败");
    }
  } else if (info.file.status === "error") {
    message.error("图片上传失败");
  }
};

const getStatusColor = (status: string) => {
  const map: any = { PENDING: "orange", COMPLETED: "green", OVERDUE: "red" };
  return map[status] || "default";
};

const getStatusLabel = (status: string) => {
  const map: any = {
    PENDING: "待完成",
    COMPLETED: "已完成",
    OVERDUE: "已逾期",
  };
  return map[status] || status;
};

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getMyTasks({
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

const handleComplete = (task: CareTask) => {
  currentTask.value = task;
  completeFileList.value = [];
  hasAbnormality.value = false;
  abnormalityForm.type = undefined;
  abnormalityForm.desc = "";
  completeModalVisible.value = true;
};

const submitComplete = async () => {
  if (!currentTask.value) return;

  if (hasAbnormality.value) {
    if (!abnormalityForm.type) {
      message.warning("请选择异常类型");
      return;
    }
    if (!abnormalityForm.desc) {
      message.warning("请填写异常描述");
      return;
    }
  }

  const notDone = completeFileList.value.some(
    (f) => f.status && f.status !== "done",
  );
  if (notDone) {
    message.warning("图片上传中，请稍后再试");
    return;
  }

  // Get raw file objects for FormData
  const files = completeFileList.value
    .map((f) => f.originFileObj)
    .filter((f) => !!f) as File[];

  if (files.length === 0) {
    message.warning("请上传照片凭证");
    return;
  }
  if (files.length > 5) {
    message.warning("最多上传5张照片");
    return;
  }

  completeLoading.value = true;
  try {
    if (hasAbnormality.value) {
      const formData = new FormData();
      formData.append("type", abnormalityForm.type!);
      formData.append("desc", abnormalityForm.desc);

      // Get user info from localStorage or define defaults
      const userInfoStr = localStorage.getItem("userInfo");
      const userInfo = userInfoStr ? JSON.parse(userInfoStr) : {};
      formData.append(
        "reporterName",
        userInfo.realName || userInfo.username || "匿名用户",
      );
      formData.append(
        "reporterContact",
        userInfo.phone || userInfo.email || "无",
      );

      files.forEach((file) => {
        formData.append("images", file);
      });

      const diagnosis = await reportAbnormalityFromTask(
        currentTask.value.id,
        formData,
      );
      message.success(
        "打卡成功，异常已上报！AI诊断建议: " + (diagnosis || "无"),
      );
    } else {
      // Use existing complete API but adapt to use FormData if you changed it,
      // or revert to just sending image URLs.
      // Wait, we changed completeTask to accept FormData OR object.
      // Let's just use the original imageUrls approach for normal completion.
      const imageUrls = completeFileList.value
        .map((f) => (f as any)?.response?.data?.url)
        .filter((u) => typeof u === "string" && u.length > 0);

      await completeTask({
        id: currentTask.value.id,
        imageUrls,
      });
      message.success("打卡成功");
    }

    completeModalVisible.value = false;
    hasAbnormality.value = false;
    abnormalityForm.type = undefined;
    abnormalityForm.desc = "";
    fetchData();
  } catch (e) {
    console.error(e);
  } finally {
    completeLoading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>
