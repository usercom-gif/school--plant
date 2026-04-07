import axios from "axios";
import { message } from "ant-design-vue";

// Create Axios instance
const service = axios.create({
  baseURL: "/api", // Use proxy
  timeout: 10000,
});

// Request interceptor
service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers["satoken"] = token; // Sa-Token header
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Response interceptor
service.interceptors.response.use(
  (response) => {
    const res = response.data;
    console.log("[API Response]", response.config.url, res);

    // Assume backend returns { code: 200, msg: "success", data: ... }
    if (res.code !== 200) {
      // Backend business error
      message.error(res.msg || "未知错误");
      if (res.code === 401) {
        // Redirect to login
        localStorage.removeItem("token");
        localStorage.removeItem("role");
        window.location.href = "/login";
      }
      return Promise.reject(new Error(res.msg || "错误"));
    } else {
      // Return the data field directly
      return res.data;
    }
  },
  (error) => {
    console.error("[API Error]", error);

    let msg = "网络连接异常";

    if (error.response) {
      const status = error.response.status;
      switch (status) {
        case 400:
          msg = "请求参数错误";
          break;
        case 401:
          msg = "未授权，请重新登录";
          break;
        case 403:
          msg = "拒绝访问";
          break;
        case 404:
          msg = "请求地址出错";
          break;
        case 408:
          msg = "请求超时";
          break;
        case 500:
          msg = "服务器内部错误";
          break;
        case 501:
          msg = "服务未实现";
          break;
        case 502:
          msg = "网关错误";
          break;
        case 503:
          msg = "服务不可用";
          break;
        case 504:
          msg = "网关超时";
          break;
        case 505:
          msg = "HTTP版本不受支持";
          break;
        default:
          msg = `连接出错(${status})`;
      }
    } else if (error.message) {
      if (error.message.includes("timeout")) {
        msg = "请求超时";
      } else if (error.message.includes("Network Error")) {
        msg = "网络连接错误";
      } else if (error.message.includes("Request failed with status code")) {
        const code = error.message.match(/\d+/)?.[0] || "未知";
        msg = `请求失败，状态码：${code}`;
      } else {
        msg = "网络连接异常";
      }
    }

    message.error(msg);
    return Promise.reject(error);
  },
);

export default service;
