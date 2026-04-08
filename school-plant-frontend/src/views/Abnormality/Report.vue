<template>
  <div class="max-w-2xl mx-auto">
    <a-card title="植物异常上报" class="shadow-sm">
      <a-form layout="vertical" :model="formState" @finish="handleSubmit">
        <a-form-item label="植物来源" v-if="adoptedPlants.length > 0">
          <a-radio-group
            v-model:value="formState.isArbitrary"
            button-style="solid"
            @change="
              () => {
                formState.plantId = undefined;
                formState.location = '';
              }
            "
          >
            <a-radio-button :value="false">我认养的植物</a-radio-button>
            <a-radio-button :value="true">校园内植物</a-radio-button>
          </a-radio-group>
        </a-form-item>

        <a-form-item
          v-if="!formState.isArbitrary"
          label="关联植物"
          name="plantId"
          :rules="[{ required: true, message: '请选择关联植物' }]"
        >
          <a-select
            v-model:value="formState.plantId"
            placeholder="选择您认养的植物"
            :options="adoptedPlants"
            show-search
            option-filter-prop="label"
          />
        </a-form-item>

        <a-form-item
          v-if="formState.isArbitrary"
          label="植物具体位置"
          name="location"
          :rules="[{ required: true, message: '请补充描述植物的具体位置' }]"
        >
          <a-input
            v-model:value="formState.location"
            placeholder="例如：图书馆前广场东南角第三棵树（必填）"
          />
        </a-form-item>

        <a-form-item
          label="异常类型"
          name="type"
          :rules="[{ required: true, message: '请选择异常类型' }]"
        >
          <a-select v-model:value="formState.type" placeholder="选择类型">
            <a-select-option value="病害">病害 (叶斑、腐烂等)</a-select-option>
            <a-select-option value="虫害"
              >虫害 (蚜虫、红蜘蛛等)</a-select-option
            >
            <a-select-option value="缺素"
              >缺素 (黄叶、生长停滞)</a-select-option
            >
            <a-select-option value="外伤"
              >物理外伤 (折断、倒伏)</a-select-option
            >
            <a-select-option value="其他">其他</a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item
          label="异常描述"
          name="desc"
          :rules="[
            { required: !formState.isArbitrary, message: '请描述具体情况' },
          ]"
        >
          <a-textarea
            v-model:value="formState.desc"
            :rows="4"
            :placeholder="
              formState.isArbitrary
                ? '请描述植物的异常症状 (选填)'
                : '请详细描述植物的异常症状...'
            "
          />
        </a-form-item>

        <a-form-item
          label="上报人姓名"
          name="reporterName"
          :rules="[{ required: true, message: '请输入您的真实姓名' }]"
        >
          <a-input
            v-model:value="formState.reporterName"
            placeholder="系统自动获取"
            disabled
          />
        </a-form-item>

        <a-form-item
          label="联系方式"
          name="reporterContact"
          :rules="[{ required: true, message: '请输入联系方式' }]"
        >
          <a-input
            v-model:value="formState.reporterContact"
            placeholder="系统自动获取"
            disabled
          />
        </a-form-item>

        <a-form-item label="现场照片" name="images">
          <a-upload
            v-model:file-list="imageFileList"
            list-type="picture-card"
            accept="image/*"
            :multiple="true"
            :max-count="5"
            :before-upload="() => false"
            @change="handleImageChange"
          >
            <div v-if="imageFileList.length < 5">
              <div class="mt-1">上传</div>
            </div>
          </a-upload>
          <div class="text-xs text-gray-500 mt-1">
            最多上传5张照片；上传后系统将尝试自动分析并给出建议。
          </div>
        </a-form-item>

        <a-form-item>
          <a-button type="primary" html-type="submit" :loading="loading" block
            >提交上报</a-button
          >
        </a-form-item>
      </a-form>
    </a-card>

    <!-- AI Analysis Result Modal -->
    <a-modal
      v-model:open="resultModalVisible"
      title="上报成功 & AI分析结果"
      :footer="null"
    >
      <a-result
        status="success"
        title="上报成功！"
        sub-title="管理员已收到您的报告，将尽快分派处理。"
      >
        <template #extra>
          <div class="bg-blue-50 p-4 rounded text-left border border-blue-100">
            <h4 class="font-bold text-blue-800 mb-2">🤖 AI 初步诊断建议：</h4>
            <p class="text-blue-700 whitespace-pre-wrap">
              {{ aiAnalysisResult }}
            </p>
          </div>
          <div class="mt-4">
            <a-button
              type="primary"
              @click="router.push('/user/my-abnormalities')"
              >查看我的上报记录</a-button
            >
          </div>
        </template>
      </a-result>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted, computed, watch } from "vue";
import { message } from "ant-design-vue";
import type { UploadChangeParam, UploadFile } from "ant-design-vue";
import { useRouter } from "vue-router";
import { reportAbnormality } from "@/api/abnormality";
import { getMyAdoptions } from "@/api/adoption";
import { getUserProfile } from "@/api/user";
import { getPlantList } from "@/api/plant"; // Import to fetch all plants

const router = useRouter();
const loading = ref(false);
const resultModalVisible = ref(false);
const aiAnalysisResult = ref("");
const adoptedPlants = ref<any[]>([]); // Store adopted plants
const allPlants = ref<any[]>([]); // Store all available plants

const formState = reactive({
  isArbitrary: false,
  plantId: undefined,
  location: "",
  type: undefined,
  desc: "",
  reporterName: "",
  reporterContact: "",
  images: [] as File[],
});

// Computed property to show correct plant list based on selection
const plantOptions = computed(() => {
  return formState.isArbitrary ? allPlants.value : adoptedPlants.value;
});

const DRAFT_KEY = "abnormality_report_draft";

// Fetch plants and user profile
onMounted(async () => {
  const draftStr = localStorage.getItem(DRAFT_KEY);
  if (draftStr) {
    try {
      const draft = JSON.parse(draftStr);
      formState.isArbitrary = draft.isArbitrary ?? false;
      formState.plantId = draft.plantId;
      formState.location = draft.location || "";
      formState.type = draft.type;
      formState.desc = draft.desc || "";
      message.info("已恢复上次未提交的草稿（图片需重新选择）");
    } catch (e) {}
  }

  try {
    const [adoptionsRes, userRes, allPlantsRes] = await Promise.all([
      getMyAdoptions({ page: 1, size: 100 }),
      getUserProfile(),
      getPlantList({ page: 1, size: 1000 }), // Fetch enough plants for dropdown
    ]);

    // Populate adopted plants
    adoptedPlants.value = (adoptionsRes as any).records.map((record: any) => ({
      label: `${record.plantName || "植物"} (ID: ${record.plantId})`,
      value: record.plantId,
    }));

    if (adoptedPlants.value.length === 0) {
      formState.isArbitrary = true;
    }

    // Populate all plants
    allPlants.value = (allPlantsRes as any).records.map((record: any) => ({
      label: `${record.name || "植物"} (位置: ${record.locationDescription})`,
      value: record.id,
    }));

    // Auto-fill reporter info
    const user = userRes as any;
    formState.reporterName = user.name || "";
    formState.reporterContact = user.phone || "";
  } catch (e) {
    console.error(e);
  }
});

watch(
  formState,
  (newVal) => {
    const draft = {
      isArbitrary: newVal.isArbitrary,
      plantId: newVal.plantId,
      location: newVal.location,
      type: newVal.type,
      desc: newVal.desc,
    };
    if (draft.desc || draft.location || draft.type) {
      localStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
    } else {
      localStorage.removeItem(DRAFT_KEY);
    }
  },
  { deep: true }
);

const imageFileList = ref<UploadFile[]>([]);

const handleImageChange = (info: UploadChangeParam) => {
  if (info.fileList.length > 5) {
    message.warning("最多只能上传5张图片");
  }
  imageFileList.value = info.fileList.slice(0, 5);
};

const handleSubmit = async () => {
  if (!formState.isArbitrary && !formState.plantId) return;
  if (formState.isArbitrary && !formState.location) {
    message.warning("请填写植物具体位置");
    return;
  }
  if (formState.isArbitrary && imageFileList.value.length === 0) {
    message.warning("上报非认养植物异常时，请至少上传一张图片");
    return;
  }

  loading.value = true;
  try {
    const images: File[] = imageFileList.value
      .map((f) => (f as any)?.originFileObj)
      .filter((f) => f instanceof File);

    const params: any = {
      type: formState.type!,
      desc: formState.desc,
      reporterName: formState.reporterName,
      reporterContact: formState.reporterContact,
      images,
    };

    if (formState.isArbitrary) {
      params.location = formState.location;
    } else {
      params.plantId = formState.plantId;
    }

    const res = await reportAbnormality(params);

    // API returns AI analysis string directly
    aiAnalysisResult.value = res || "暂无AI建议";
    resultModalVisible.value = true;
    localStorage.removeItem(DRAFT_KEY);
  } catch (error: any) {
    console.error(error);
    message.error(error.response?.data?.msg || "提交失败，文本内容已自动保存为草稿");
  } finally {
    loading.value = false;
  }
};
</script>
