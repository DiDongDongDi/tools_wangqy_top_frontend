<template>
  <div class="dashboard-base">
    <text-compare />
  </div>
</template>
<script setup lang="ts">
import TextCompare from '@/components/text-compare/index.vue';

defineOptions({
  name: 'DashboardBase',
});
</script>
<style scoped>
.dashboard-base {
  min-height: 100vh;
  background-color: var(--td-bg-color-page);
}
</style>
