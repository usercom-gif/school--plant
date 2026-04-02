import { createApp } from 'vue'
import { createPinia } from 'pinia'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import './style.css'
import App from './App.vue'
import router from './router'

// 创建Vue应用实例
const app = createApp(App)

// 使用Pinia
const pinia = createPinia()
app.use(pinia)

// 使用Ant Design Vue
app.use(Antd)

// 使用路由
app.use(router)

// 挂载应用
app.mount('#app')
