<template>
  <result title="500 Internal Server Error" type="500" :tip="t('pages.result.500.subtitle')">
    <t-button @click="() => $router.push('/')">{{ t('pages.result.500.back') }}</t-button>
  </result>
</template>
<script setup lang="ts">
import Result from '@/components/result/index.vue';
import { t } from '@/locales';

defineOptions({
  name: 'Result500',
});
</script>
