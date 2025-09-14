<script setup>
import { ref } from 'vue'
const count = ref(0)
const welcomeMessage = ref('Welcome to Vue!')

// 动态修改欢迎信息的方法
const changeWelcomeMessage = () => {
  const messages = [
    'Welcome to Vue!',
    'Hello Vue 3!',
    'Vue is awesome!',
    'Learning Vue is fun!',
    'Vue 3 Composition API rocks!',
    'Welcome to the future!',
  ]
  const currentIndex = messages.indexOf(welcomeMessage.value)
  const nextIndex = (currentIndex + 1) % messages.length
  welcomeMessage.value = messages[nextIndex]
}
</script>

<template>
  <h1>You did it!</h1>
  <button @click="count++">Click me</button>
  <p>Count is: {{ count }}</p>
  <p>
    Visit <a href="https://vuejs.org/" target="_blank" rel="noopener">vuejs.org</a> to read the
    documentation
  </p>
  <div
    class="min-h-screen bg-gradient-to-r from-blue-500 to-purple-600 flex items-center justify-center"
  >
    <div class="bg-white p-8 rounded-lg shadow-lg">
      <h1 class="text-3xl font-bold text-gray-800 mb-4">{{ welcomeMessage }}</h1>
      <p class="text-gray-600">Tailwind CSS is working perfectly!</p>
      <button
        @click="changeWelcomeMessage"
        class="mt-4 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition-colors duration-200"
      >
        改变欢迎信息
      </button>
    </div>
  </div>
</template>

<style scoped></style>
