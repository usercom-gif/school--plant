<template>
  <div
    class="min-h-screen flex items-center justify-center bg-cover bg-center bg-no-repeat"
    style="
      background-image: url(&quot;https://images.unsplash.com/photo-1518531933037-9a8476317d1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80&quot;);
      background-color: #f0f2f5;
    "
  >
    <!-- Overlay -->
    <div class="absolute inset-0 bg-black bg-opacity-30 backdrop-blur-sm"></div>

    <div
      class="relative z-10 w-full max-w-4xl flex flex-col md:flex-row shadow-2xl rounded-2xl overflow-hidden bg-white/90 backdrop-blur-md m-4 min-h-[500px]"
    >
      <!-- Left Side -->
      <div
        class="hidden md:flex md:w-1/2 bg-gradient-to-br from-green-600 to-teal-700 p-10 flex-col justify-between text-white relative overflow-hidden"
      >
        <div
          class="absolute top-0 left-0 w-full h-full opacity-20"
          style="
            background-image: url(&quot;https://www.transparenttextures.com/patterns/leaf.png&quot;);
          "
        ></div>
        <div>
          <h1 class="text-4xl font-bold mb-4">校园植物<br />认养与养护</h1>
          <p class="text-green-100 text-lg">
            致力于打造绿色校园，<br />让每一株植物都有专属守护者。
          </p>
        </div>
        <div class="text-sm opacity-80">
          © {{ new Date().getFullYear() }} School Plant System
        </div>
      </div>

      <!-- Right Side -->
      <div
        class="w-full md:w-1/2 p-4 md:p-12 bg-white flex flex-col justify-center"
      >
        <div class="text-center mb-6 md:hidden mt-4">
          <h2 class="text-2xl font-bold text-green-600">校园植物认养与养护</h2>
          <p class="text-gray-500 text-sm mt-2">绿色校园 · 专属守护</p>
        </div>

        <a-tabs
          v-model:activeKey="activeTab"
          centered
          size="large"
          class="mb-6"
        >
          <a-tab-pane key="login" tab="账号登录" />
          <a-tab-pane key="register" tab="新用户注册" />
        </a-tabs>

        <a-form
          layout="vertical"
          :model="formState"
          @finish="onFinish"
          size="large"
        >
          <a-form-item
            name="username"
            :rules="[{ required: true, message: '请输入用户名!' }]"
          >
            <a-input v-model:value="formState.username" placeholder="用户名">
              <template #prefix
                ><UserOutlined class="text-gray-400"
              /></template>
            </a-input>
          </a-form-item>

          <template v-if="activeTab === 'register'">
            <a-form-item
              name="studentId"
              :rules="[{ required: true, message: '请输入学号/职工号!' }]"
            >
              <a-input
                v-model:value="formState.studentId"
                placeholder="学号/职工号"
              >
                <template #prefix
                  ><IdcardOutlined class="text-gray-400"
                /></template>
              </a-input>
            </a-form-item>
            <a-form-item
              name="phone"
              :rules="[
                { required: true, message: '请输入手机号!' },
                {
                  pattern: /^1[3-9]\d{9}$/,
                  message: '请输入有效的11位手机号!',
                },
              ]"
            >
              <a-input v-model:value="formState.phone" placeholder="手机号">
                <template #prefix
                  ><PhoneOutlined class="text-gray-400"
                /></template>
              </a-input>
            </a-form-item>
            <a-form-item
              name="email"
              :rules="[
                { required: true, message: '请输入邮箱!' },
                { type: 'email', message: '邮箱格式不正确!' },
              ]"
            >
              <a-input v-model:value="formState.email" placeholder="邮箱">
                <template #prefix
                  ><MailOutlined class="text-gray-400"
                /></template>
              </a-input>
            </a-form-item>
          </template>

          <a-form-item
            name="password"
            :rules="[{ required: true, message: '请输入密码!' }]"
          >
            <a-input-password
              v-model:value="formState.password"
              placeholder="密码"
            >
              <template #prefix
                ><LockOutlined class="text-gray-400"
              /></template>
            </a-input-password>
          </a-form-item>

          <template v-if="activeTab === 'register'">
            <a-form-item
              name="confirmPassword"
              :rules="[
                { required: true, message: '请确认密码!' },
                { validator: validateConfirmPassword },
              ]"
            >
              <a-input-password
                v-model:value="formState.confirmPassword"
                placeholder="确认密码"
              >
                <template #prefix
                  ><SafetyOutlined class="text-gray-400"
                /></template>
              </a-input-password>
            </a-form-item>
          </template>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              class="w-full h-12 text-lg font-medium shadow-md hover:shadow-lg transition-all"
              :loading="loading"
            >
              {{ activeTab === "login" ? "立即登录" : "立即注册" }}
            </a-button>
          </a-form-item>
        </a-form>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive } from "vue";
import {
  UserOutlined,
  LockOutlined,
  MailOutlined,
  PhoneOutlined,
  SafetyOutlined,
  IdcardOutlined,
} from "@ant-design/icons-vue";
import { message } from "ant-design-vue";
import { useRouter } from "vue-router";
import { login, register } from "@/api/auth";
import CryptoJS from "crypto-js";

const router = useRouter();
const activeTab = ref("login");
const loading = ref(false);

const formState = reactive({
  username: "",
  studentId: "",
  password: "",
  confirmPassword: "",
  phone: "",
  email: "",
});

const validateConfirmPassword = async (_rule: any, value: string) => {
  if (value && value !== formState.password) {
    return Promise.reject("两次输入的密码不一致!");
  }
  return Promise.resolve();
};

const onFinish = async (values: any) => {
  loading.value = true;
  try {
    if (activeTab.value === "login") {
      // Login
      const payload = {
        username: values.username,
        password: values.password, // Send plaintext, let backend handle or frontend encrypt if agreed.
        // Wait, backend AuthController line 44: SecurityUtils.encryptPassword(request.getPassword());
        // And SecurityUtils usually does MD5.
        // If frontend sends MD5, and backend encrypts AGAIN, then DB must store Double-MD5.
        // Let's check SecurityUtils.java.
        // BUT, usually standard is HTTPS + Plaintext or Frontend MD5 + Backend verification.
        // The current code below was doing: values.password = MD5(values.password).
        // Let's stick to what was there but fix the request structure if needed.
      };

      // Re-implementing the encryption logic from previous code block but cleaner
      // Note: The previous code was modifying `values` which might be reactive form state?
      // Better create a new object.
      const loginData = {
        username: values.username,
        password: CryptoJS.MD5(values.password).toString(),
      };

      const res: any = await login(loginData);
      console.log("Login Response:", res);

      // The request interceptor already unwraps `res.data` if code===200.
      // So `res` here IS the data object (containing tokenInfo, etc).

      if (res && res.tokenInfo) {
        localStorage.setItem("token", res.tokenInfo.tokenValue);
        localStorage.setItem("role", res.roleType);
        localStorage.setItem("username", res.username);
        localStorage.setItem("realName", res.realName);
        localStorage.setItem("userId", res.userId); // Store ID
        if (res.avatarUrl) {
          localStorage.setItem("avatarUrl", res.avatarUrl);
        } else {
          localStorage.removeItem("avatarUrl");
        }

        message.success("登录成功");
        // Delay navigation slightly to ensure token is set and UI updates
        setTimeout(() => {
          // Force reload to ensure clean state and avoid router issues
          window.location.href = "/user/overview";
        }, 500);
      } else {
        message.error("登录失败");
      }
    } else {
      // Register
      if (values.password !== values.confirmPassword) {
        message.error("两次密码不一致");
        return;
      }

      const registerData = {
        username: values.username,
        studentId: values.studentId,
        password: CryptoJS.MD5(values.password).toString(),
        confirmPassword: CryptoJS.MD5(values.confirmPassword).toString(),
        phone: values.phone,
        email: values.email,
      };

      await register(registerData);
      message.success("注册成功，请登录");
      activeTab.value = "login";
    }
  } catch (error) {
    console.error(error);
    // Error message handled by interceptor usually
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
/* Add any additional custom styles here */
</style>
