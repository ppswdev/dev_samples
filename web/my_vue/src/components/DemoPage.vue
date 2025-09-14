<script setup>
import { ref, onMounted } from 'vue'

const isMenuOpen = ref(false)
const email = ref('')
const isSubscribed = ref(false)
const isScrolled = ref(false)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const subscribeEmail = () => {
  if (email.value) {
    isSubscribed.value = true
    email.value = ''
    setTimeout(() => {
      isSubscribed.value = false
    }, 3000)
  }
}

const scrollToSection = (sectionId) => {
  document.getElementById(sectionId)?.scrollIntoView({ behavior: 'smooth' })
  isMenuOpen.value = false
}

onMounted(() => {
  window.addEventListener('scroll', () => {
    isScrolled.value = window.scrollY > 50
  })
})
</script>

<template>
  <div class="min-h-screen bg-white">
    <!-- 导航栏 -->
    <nav
      class="fixed w-full z-50 transition-all duration-300"
      :class="isScrolled ? 'bg-white/95 backdrop-blur-md shadow-lg' : 'bg-transparent'"
    >
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-3">
            <div
              class="w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg"
            >
              <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>
            <h1
              class="text-2xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent"
            >
              ProductName
            </h1>
          </div>

          <div class="hidden md:flex items-center space-x-2">
            <button
              @click="scrollToSection('features')"
              class="px-4 py-2 text-gray-700 hover:text-blue-600 rounded-lg hover:bg-blue-50 transition-all duration-200 font-medium"
            >
              功能特性
            </button>
            <button
              @click="scrollToSection('pricing')"
              class="px-4 py-2 text-gray-700 hover:text-blue-600 rounded-lg hover:bg-blue-50 transition-all duration-200 font-medium"
            >
              价格方案
            </button>
            <button
              @click="scrollToSection('testimonials')"
              class="px-4 py-2 text-gray-700 hover:text-blue-600 rounded-lg hover:bg-blue-50 transition-all duration-200 font-medium"
            >
              用户评价
            </button>
          </div>

          <div class="hidden md:block">
            <button
              class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-6 py-2.5 rounded-xl font-medium transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
            >
              免费试用
            </button>
          </div>

          <div class="md:hidden">
            <button
              @click="toggleMenu"
              class="text-gray-700 hover:text-blue-600 p-2 rounded-lg hover:bg-blue-50 transition-colors"
            >
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <div v-if="isMenuOpen" class="md:hidden bg-white/95 backdrop-blur-md border-t shadow-lg">
        <div class="px-2 pt-2 pb-3 space-y-1">
          <button
            @click="scrollToSection('features')"
            class="block w-full text-left px-3 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
          >
            功能特性
          </button>
          <button
            @click="scrollToSection('pricing')"
            class="block w-full text-left px-3 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
          >
            价格方案
          </button>
          <button
            @click="scrollToSection('testimonials')"
            class="block w-full text-left px-3 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
          >
            用户评价
          </button>
        </div>
      </div>
    </nav>

    <!-- Hero区域 -->
    <section class="pt-16 relative overflow-hidden">
      <div class="absolute inset-0 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50"></div>
      <div
        class="absolute top-20 left-10 w-72 h-72 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-pulse"
      ></div>
      <div
        class="absolute top-40 right-10 w-72 h-72 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-pulse"
        style="animation-delay: 2s"
      ></div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
        <div class="text-center">
          <div
            class="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-medium mb-8 shadow-md"
          >
            <span class="w-2 h-2 bg-blue-600 rounded-full mr-2 animate-pulse"></span>
            新功能发布：AI智能助手
          </div>

          <h1 class="text-5xl md:text-7xl font-bold text-gray-900 mb-8 leading-tight">
            让工作更高效的
            <span
              class="bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent"
              >智能工具</span
            >
          </h1>

          <p class="text-xl md:text-2xl text-gray-600 mb-12 max-w-4xl mx-auto leading-relaxed">
            我们提供最先进的产品解决方案，帮助团队提升工作效率，实现业务目标。
            <span class="font-semibold text-blue-600">已有超过10万+企业选择我们的产品。</span>
          </p>

          <div class="flex flex-col sm:flex-row gap-6 justify-center mb-16">
            <button
              class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-10 py-4 rounded-xl text-lg font-medium transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
            >
              <span class="flex items-center justify-center">
                免费开始使用
                <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 7l5 5m0 0l-5 5m5-5H6"
                  ></path>
                </svg>
              </span>
            </button>
            <button
              class="border-2 border-gray-300 hover:border-blue-500 text-gray-700 hover:text-blue-600 px-10 py-4 rounded-xl text-lg font-medium transition-all duration-200 hover:bg-blue-50"
            >
              <span class="flex items-center justify-center">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-6 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  ></path>
                </svg>
                观看演示
              </span>
            </button>
          </div>

          <!-- 信任指标 -->
          <div class="flex flex-wrap justify-center items-center gap-8 text-gray-500">
            <div class="flex items-center bg-white px-4 py-2 rounded-lg shadow-md">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                ></path>
              </svg>
              <span class="text-sm font-medium">30天免费试用</span>
            </div>
            <div class="flex items-center bg-white px-4 py-2 rounded-lg shadow-md">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                ></path>
              </svg>
              <span class="text-sm font-medium">无需信用卡</span>
            </div>
            <div class="flex items-center bg-white px-4 py-2 rounded-lg shadow-md">
              <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                ></path>
              </svg>
              <span class="text-sm font-medium">24/7技术支持</span>
            </div>
          </div>
        </div>

        <!-- 产品展示 -->
        <div class="mt-24">
          <div class="relative max-w-6xl mx-auto">
            <div class="bg-white rounded-3xl shadow-2xl p-8 border border-gray-100">
              <div
                class="bg-gradient-to-br from-gray-50 to-gray-100 rounded-2xl h-96 flex items-center justify-center relative overflow-hidden"
              >
                <img
                  src="https://picsum.photos/800/400?random=1"
                  alt="产品界面展示"
                  class="absolute inset-0 w-full h-full object-cover rounded-2xl opacity-20"
                />
                <div
                  class="absolute inset-6 bg-white/90 backdrop-blur-sm rounded-xl shadow-inner p-6"
                >
                  <div class="flex items-center justify-between mb-6">
                    <div class="flex space-x-2">
                      <div class="w-4 h-4 bg-red-400 rounded-full"></div>
                      <div class="w-4 h-4 bg-yellow-400 rounded-full"></div>
                      <div class="w-4 h-4 bg-green-400 rounded-full"></div>
                    </div>
                    <div class="text-lg font-medium text-gray-600">ProductName Dashboard</div>
                  </div>
                  <div class="grid grid-cols-3 gap-6 mb-6">
                    <div class="bg-gradient-to-br from-blue-100 to-blue-200 rounded-xl p-4">
                      <div class="w-12 h-12 bg-blue-500 rounded-lg mb-3"></div>
                      <div class="h-3 bg-blue-400 rounded mb-2"></div>
                      <div class="h-2 bg-blue-300 rounded w-3/4"></div>
                    </div>
                    <div class="bg-gradient-to-br from-green-100 to-green-200 rounded-xl p-4">
                      <div class="w-12 h-12 bg-green-500 rounded-lg mb-3"></div>
                      <div class="h-3 bg-green-400 rounded mb-2"></div>
                      <div class="h-2 bg-green-300 rounded w-2/3"></div>
                    </div>
                    <div class="bg-gradient-to-br from-purple-100 to-purple-200 rounded-xl p-4">
                      <div class="w-12 h-12 bg-purple-500 rounded-lg mb-3"></div>
                      <div class="h-3 bg-purple-400 rounded mb-2"></div>
                      <div class="h-2 bg-purple-300 rounded w-4/5"></div>
                    </div>
                  </div>
                  <div class="bg-gradient-to-r from-gray-100 to-gray-200 rounded-lg p-4">
                    <div class="h-3 bg-gray-400 rounded mb-3"></div>
                    <div class="h-2 bg-gray-300 rounded w-5/6"></div>
                  </div>
                </div>
                <div
                  class="absolute bottom-6 right-6 bg-gradient-to-r from-blue-500 to-purple-500 text-white px-6 py-3 rounded-lg text-sm font-medium shadow-lg"
                >
                  实时数据更新
                </div>
              </div>
            </div>

            <div
              class="absolute -top-6 -left-6 w-24 h-24 bg-blue-400 rounded-full opacity-20 animate-bounce"
            ></div>
            <div
              class="absolute -bottom-6 -right-6 w-20 h-20 bg-purple-400 rounded-full opacity-20 animate-bounce"
              style="animation-delay: 1s"
            ></div>
          </div>
        </div>
      </div>
    </section>

    <!-- 功能特性区域 -->
    <section id="features" class="py-24 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-20">
          <div
            class="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-medium mb-6 shadow-md"
          >
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            功能特性
          </div>
          <h2 class="text-4xl md:text-5xl font-bold text-gray-900 mb-6">强大的功能特性</h2>
          <p class="text-xl text-gray-600 max-w-3xl mx-auto">
            为您的业务提供全方位的解决方案，让工作变得更加高效和智能
          </p>
        </div>

        <div class="grid md:grid-cols-3 gap-10">
          <div
            class="group text-center p-10 rounded-2xl hover:bg-gradient-to-br hover:from-blue-50 hover:to-indigo-50 transition-all duration-300 hover:shadow-xl hover:-translate-y-2"
          >
            <div
              class="bg-gradient-to-r from-blue-500 to-blue-600 w-24 h-24 rounded-2xl flex items-center justify-center mx-auto mb-8 group-hover:scale-110 transition-transform duration-300 shadow-lg"
            >
              <svg
                class="w-12 h-12 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 10V3L4 14h7v7l9-11h-7z"
                ></path>
              </svg>
            </div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">极速处理</h3>
            <p class="text-gray-600 leading-relaxed text-lg">
              采用最新技术，处理速度提升300%，让您的工作效率翻倍。支持实时数据处理和智能分析。
            </p>
          </div>

          <div
            class="group text-center p-10 rounded-2xl hover:bg-gradient-to-br hover:from-green-50 hover:to-emerald-50 transition-all duration-300 hover:shadow-xl hover:-translate-y-2"
          >
            <div
              class="bg-gradient-to-r from-green-500 to-green-600 w-24 h-24 rounded-2xl flex items-center justify-center mx-auto mb-8 group-hover:scale-110 transition-transform duration-300 shadow-lg"
            >
              <svg
                class="w-12 h-12 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                ></path>
              </svg>
            </div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">安全可靠</h3>
            <p class="text-gray-600 leading-relaxed text-lg">
              企业级安全保障，数据加密传输，确保您的信息安全。通过ISO 27001认证，值得信赖。
            </p>
          </div>

          <div
            class="group text-center p-10 rounded-2xl hover:bg-gradient-to-br hover:from-purple-50 hover:to-pink-50 transition-all duration-300 hover:shadow-xl hover:-translate-y-2"
          >
            <div
              class="bg-gradient-to-r from-purple-500 to-purple-600 w-24 h-24 rounded-2xl flex items-center justify-center mx-auto mb-8 group-hover:scale-110 transition-transform duration-300 shadow-lg"
            >
              <svg
                class="w-12 h-12 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                ></path>
              </svg>
            </div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">易于使用</h3>
            <p class="text-gray-600 leading-relaxed text-lg">
              直观的用户界面，简单易学，让您快速上手，无需复杂培训。支持拖拽操作和智能提示。
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- 用户评价区域 -->
    <section id="testimonials" class="py-24 bg-gradient-to-br from-gray-50 to-blue-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-20">
          <div
            class="inline-flex items-center px-4 py-2 rounded-full bg-green-100 text-green-800 text-sm font-medium mb-6 shadow-md"
          >
            <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path
                d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
              ></path>
            </svg>
            用户评价
          </div>
          <h2 class="text-4xl md:text-5xl font-bold text-gray-900 mb-6">用户怎么说</h2>
          <p class="text-xl text-gray-600">
            来自真实用户的反馈，了解他们如何通过我们的产品取得成功
          </p>
        </div>

        <div class="grid md:grid-cols-3 gap-8">
          <div
            class="bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100"
          >
            <div class="flex items-center mb-6">
              <img
                src="https://picsum.photos/64/64?random=2"
                alt="张经理"
                class="w-16 h-16 rounded-full object-cover shadow-lg"
              />
              <div class="ml-4">
                <h4 class="font-bold text-gray-900 text-lg">张经理</h4>
                <p class="text-gray-600">某科技公司 CTO</p>
                <div class="flex text-yellow-400 mt-1">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                </div>
              </div>
            </div>
            <p class="text-gray-700 leading-relaxed">
              "这个产品大大提升了我们团队的工作效率，界面简洁易用，功能强大。从免费试用开始，现在已经是我们团队不可或缺的工具了。"
            </p>
          </div>

          <div
            class="bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100"
          >
            <div class="flex items-center mb-6">
              <img
                src="https://picsum.photos/64/64?random=3"
                alt="李总监"
                class="w-16 h-16 rounded-full object-cover shadow-lg"
              />
              <div class="ml-4">
                <h4 class="font-bold text-gray-900 text-lg">李总监</h4>
                <p class="text-gray-600">某互联网公司</p>
                <div class="flex text-yellow-400 mt-1">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                </div>
              </div>
            </div>
            <p class="text-gray-700 leading-relaxed">
              "性价比很高，客服响应及时，是我们用过最好的工具之一。数据安全方面做得很好，让我们很放心。"
            </p>
          </div>

          <div
            class="bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100"
          >
            <div class="flex items-center mb-6">
              <img
                src="https://picsum.photos/64/64?random=4"
                alt="王总"
                class="w-16 h-16 rounded-full object-cover shadow-lg"
              />
              <div class="ml-4">
                <h4 class="font-bold text-gray-900 text-lg">王总</h4>
                <p class="text-gray-600">某创业公司</p>
                <div class="flex text-yellow-400 mt-1">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                    ></path>
                  </svg>
                </div>
              </div>
            </div>
            <p class="text-gray-700 leading-relaxed">
              "从免费试用开始，现在已经是我们团队不可或缺的工具了。界面设计很现代化，功能也很全面。"
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- 最终CTA区域 -->
    <section
      class="py-24 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 relative overflow-hidden"
    >
      <div class="absolute inset-0">
        <div
          class="absolute top-10 left-10 w-64 h-64 bg-white rounded-full opacity-10 animate-pulse"
        ></div>
        <div
          class="absolute bottom-10 right-10 w-64 h-64 bg-white rounded-full opacity-10 animate-pulse"
          style="animation-delay: 2s"
        ></div>
      </div>

      <div class="relative max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
        <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">准备开始了吗？</h2>
        <p class="text-xl md:text-2xl text-blue-100 mb-12 leading-relaxed">
          立即注册，享受30天免费试用，无需信用卡，开始您的智能工作之旅
        </p>

        <div class="flex flex-col sm:flex-row gap-6 justify-center mb-12">
          <button
            class="bg-white hover:bg-gray-100 text-blue-600 px-10 py-4 rounded-xl text-lg font-bold transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
          >
            免费开始使用
          </button>
          <button
            class="border-2 border-white hover:bg-white/10 text-white px-10 py-4 rounded-xl text-lg font-medium transition-all duration-200"
          >
            联系我们
          </button>
        </div>

        <!-- 最终信任指标 -->
        <div class="flex flex-wrap justify-center items-center gap-8 text-blue-100">
          <div class="flex items-center">
            <svg class="w-6 h-6 text-white mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              ></path>
            </svg>
            <span class="text-lg font-medium">10万+ 企业信赖</span>
          </div>
          <div class="flex items-center">
            <svg class="w-6 h-6 text-white mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              ></path>
            </svg>
            <span class="text-lg font-medium">99.9% 服务可用性</span>
          </div>
          <div class="flex items-center">
            <svg class="w-6 h-6 text-white mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              ></path>
            </svg>
            <span class="text-lg font-medium">24/7 专业支持</span>
          </div>
        </div>
      </div>
    </section>

    <!-- 页脚 -->
    <footer class="bg-gray-900 text-white py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center">
          <div class="flex items-center justify-center space-x-3 mb-6">
            <div
              class="w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg"
            >
              <svg class="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>
            <h3 class="text-2xl font-bold">ProductName</h3>
          </div>
          <p class="text-gray-400 mb-8 max-w-2xl mx-auto">
            让工作更高效的智能工具，为您的团队提供全方位的解决方案，提升工作效率，实现业务目标。
          </p>

          <!-- 邮件订阅 -->
          <div class="flex max-w-md mx-auto mb-8">
            <input
              v-model="email"
              type="email"
              placeholder="输入邮箱地址获取最新资讯"
              class="flex-1 px-4 py-3 bg-gray-800 border border-gray-700 rounded-l-lg text-white placeholder-gray-400 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20"
            />
            <button
              @click="subscribeEmail"
              class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 px-6 py-3 rounded-r-lg font-medium transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              订阅
            </button>
          </div>
          <p v-if="isSubscribed" class="text-green-400 text-sm">🎉 订阅成功！感谢您的关注！</p>

          <div class="border-t border-gray-800 pt-8 mt-12">
            <p class="text-gray-400 text-sm">© 2024 ProductName. 保留所有权利。</p>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped></style>
