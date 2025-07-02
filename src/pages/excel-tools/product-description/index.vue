<template>
  <div class="product-description-container">
    <t-card :title="t('pages.excelTools.productDescription.title')" class="main-card">
      <!-- 文件上传区域 -->
      <div class="upload-section">
        <t-upload
          v-model="fileList"
          :action="uploadUrl"
          :headers="uploadHeaders"
          :data="uploadData"
          :before-upload="beforeUpload"
          :on-success="onUploadSuccess"
          :on-error="onUploadError"
          accept=".xlsx,.xls"
          theme="file-input"
          :placeholder="t('pages.excelTools.productDescription.upload.placeholder')"
          :max="1"
          :disabled="uploading"
        >
          <t-button theme="primary" :loading="uploading">
            <template #icon>
              <upload-icon />
            </template>
            {{
              uploading
                ? t('pages.excelTools.productDescription.upload.uploading')
                : t('pages.excelTools.productDescription.upload.button')
            }}
          </t-button>
        </t-upload>
      </div>

      <!-- 文件信息展示 -->
      <div v-if="fileInfo" class="file-info">
        <t-alert
          theme="success"
          :message="`${t('pages.excelTools.productDescription.upload.success')}: ${fileInfo.file_name}`"
        />
        <div class="file-details">
          <p>{{ t('pages.excelTools.productDescription.fileInfo.size') }}: {{ formatFileSize(fileInfo.file_size) }}</p>
          <p>{{ t('pages.excelTools.productDescription.fileInfo.rows') }}: {{ fileInfo.excel_info.total_rows }}</p>
          <p>
            {{ t('pages.excelTools.productDescription.fileInfo.columns') }}: {{ fileInfo.excel_info.total_columns }}
          </p>
        </div>
      </div>

      <!-- 产品描述列表 -->
      <div v-if="productDescriptions.length > 0" class="product-list">
        <div class="list-header">
          <h3>{{ t('pages.excelTools.productDescription.productList.title') }}</h3>
          <div class="actions">
            <t-button theme="primary" @click="selectAll">{{
              t('pages.excelTools.productDescription.productList.selectAll')
            }}</t-button>
            <t-button theme="default" @click="deselectAll">{{
              t('pages.excelTools.productDescription.productList.deselectAll')
            }}</t-button>
          </div>
        </div>

        <div class="product-groups">
          <div v-for="(group, groupIndex) in productDescriptions" :key="groupIndex" class="product-group">
            <div class="group-header">
              <h4>产品组 {{ groupIndex + 1 }}</h4>
              <span class="group-count">({{ group.length }} 个描述)</span>
            </div>

            <div class="group-items">
              <div v-for="(description, descIndex) in group" :key="descIndex" class="description-item">
                <t-checkbox
                  v-model="selectedItems[groupIndex][descIndex]"
                  :disabled="!isItemInAI(groupIndex, descIndex)"
                >
                  <div class="description-content">
                    <span class="description-text" :class="{ 'ai-filtered': !isItemInAI(groupIndex, descIndex) }">
                      {{ description }}
                    </span>
                  </div>
                </t-checkbox>
              </div>
            </div>
          </div>
        </div>
      </div>
    </t-card>
  </div>
</template>
<script setup lang="ts">
import { UploadIcon } from 'tdesign-icons-vue-next';
import type { SuccessContext, UploadFile } from 'tdesign-vue-next';
import { MessagePlugin } from 'tdesign-vue-next';
import { computed, ref } from 'vue';

import { t } from '@/locales';

interface FileInfo {
  file_name: string;
  file_size: number;
  excel_info: {
    total_rows: number;
    total_columns: number;
    product_descriptions: string[][];
    product_descriptions_ai: string[][];
  };
}

interface UploadResponse {
  success: boolean;
  message: string;
  file_name: string;
  file_size: number;
  excel_info: {
    total_rows: number;
    total_columns: number;
    product_descriptions: string[][];
    product_descriptions_ai: string[][];
  };
}

// 响应式数据
const fileList = ref([]);
const uploading = ref(false);
const fileInfo = ref<FileInfo | null>(null);
const productDescriptions = ref<string[][]>([]);
const productDescriptionsAI = ref<string[][]>([]);
const selectedItems = ref<boolean[][]>([]);

// 计算属性
const uploadUrl = computed(() => '/api/excel-tools/file/upload');
const uploadHeaders = computed(() => ({}));
const uploadData = computed(() => ({}));

// 方法
const beforeUpload = (file: UploadFile) => {
  const isExcel =
    file.raw?.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    file.raw?.type === 'application/vnd.ms-excel';
  if (!isExcel) {
    MessagePlugin.error(t('pages.excelTools.productDescription.upload.accept'));
    return false;
  }

  const isLt10M = (file.raw?.size || 0) / 1024 / 1024 < 10;
  if (!isLt10M) {
    MessagePlugin.error(t('pages.excelTools.productDescription.upload.sizeLimit'));
    return false;
  }

  uploading.value = true;
  return true;
};

const onUploadSuccess = (context: SuccessContext) => {
  uploading.value = false;
  const response = context.response as UploadResponse;

  if (response.success) {
    fileInfo.value = {
      file_name: response.file_name,
      file_size: response.file_size,
      excel_info: response.excel_info,
    };

    productDescriptions.value = response.excel_info.product_descriptions;
    productDescriptionsAI.value = response.excel_info.product_descriptions_ai;

    // 初始化选中状态 - 二维数组
    selectedItems.value = productDescriptions.value.map((group) => Array.from({ length: group.length }, () => false));

    MessagePlugin.success(t('pages.excelTools.productDescription.upload.success'));
  } else {
    MessagePlugin.error(response.message || t('pages.excelTools.productDescription.upload.error'));
  }
};

const onUploadError = (error: any) => {
  uploading.value = false;
  MessagePlugin.error(t('pages.excelTools.productDescription.upload.error'));
  console.error('Upload error:', error);
};

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${Number.parseFloat((bytes / k ** i).toFixed(2))} ${sizes[i]}`;
};

const isItemInAI = (groupIndex: number, descIndex: number): boolean => {
  const item = productDescriptions.value[groupIndex][descIndex];
  return productDescriptionsAI.value.some((aiGroup) => aiGroup.includes(item));
};

const selectAll = () => {
  selectedItems.value = selectedItems.value.map((group, groupIndex) =>
    group.map((_, descIndex) => isItemInAI(groupIndex, descIndex)),
  );
};

const deselectAll = () => {
  selectedItems.value = selectedItems.value.map((group) => group.map(() => false));
};
</script>
<style scoped>
.product-description-container {
  padding: 20px;
}

.main-card {
  max-width: 1200px;
  margin: 0 auto;
}

.upload-section {
  margin-bottom: 24px;
  padding: 20px;
  border: 2px dashed #dcdcdc;
  border-radius: 8px;
  text-align: center;
}

.file-info {
  margin-bottom: 24px;
}

.file-details {
  margin-top: 12px;
  padding: 12px;
  background-color: #f5f5f5;
  border-radius: 6px;
}

.file-details p {
  margin: 4px 0;
  color: #666;
}

.product-list {
  margin-top: 24px;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e7e7e7;
}

.list-header h3 {
  margin: 0;
  color: #333;
}

.actions {
  display: flex;
  gap: 8px;
}

.product-groups {
  max-height: 600px;
  overflow-y: auto;
}

.product-group {
  margin-bottom: 24px;
  padding: 16px;
  border: 1px solid #e7e7e7;
  border-radius: 8px;
  background-color: #fafafa;
}

.group-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}

.group-header h4 {
  margin: 0;
  color: #333;
  font-size: 16px;
  font-weight: 600;
}

.group-count {
  margin-left: 8px;
  color: #666;
  font-size: 14px;
}

.group-items {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 8px;
}

.description-item {
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background-color: #fff;
  transition: all 0.2s ease;
}

.description-item:hover {
  border-color: #0052d9;
  box-shadow: 0 2px 4px rgba(0, 82, 217, 0.1);
}

.description-content {
  margin-left: 8px;
}

.description-text {
  font-size: 14px;
  color: #333;
  line-height: 1.5;
}

.description-text.ai-filtered {
  color: #d32f2f;
  text-decoration: line-through;
  opacity: 0.6;
}

/* 滚动条样式 */
.product-groups::-webkit-scrollbar {
  width: 6px;
}

.product-groups::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.product-groups::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.product-groups::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
