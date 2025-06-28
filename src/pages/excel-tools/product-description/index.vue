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

        <div class="product-items">
          <div v-for="(item, index) in productDescriptions" :key="index" class="product-item">
            <t-checkbox v-model="selectedItems[index]" :disabled="!isItemInAI(index)">
              <div class="product-content">
                <div class="product-row">
                  <span
                    v-for="(cell, cellIndex) in item"
                    :key="cellIndex"
                    class="product-cell"
                    :class="{ 'ai-filtered': !isItemInAI(index) }"
                  >
                    {{ cell }}
                  </span>
                </div>
              </div>
            </t-checkbox>
          </div>
        </div>
      </div>
    </t-card>
  </div>
</template>
<script setup lang="ts">
import { UploadIcon } from 'tdesign-icons-vue-next';
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
const selectedItems = ref<boolean[]>([]);

// 计算属性
const uploadUrl = computed(() => 'api/excel-tools/file/upload');
const uploadHeaders = computed(() => ({}));
const uploadData = computed(() => ({}));

// 方法
const beforeUpload = (file: File) => {
  const isExcel =
    file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    file.type === 'application/vnd.ms-excel';
  if (!isExcel) {
    MessagePlugin.error(t('pages.excelTools.productDescription.upload.accept'));
    return false;
  }

  const isLt10M = file.size / 1024 / 1024 < 10;
  if (!isLt10M) {
    MessagePlugin.error(t('pages.excelTools.productDescription.upload.sizeLimit'));
    return false;
  }

  uploading.value = true;
  return true;
};

const onUploadSuccess = (response: UploadResponse, file: File) => {
  uploading.value = false;

  if (response.success) {
    fileInfo.value = {
      file_name: response.file_name,
      file_size: response.file_size,
      excel_info: response.excel_info,
    };

    productDescriptions.value = response.excel_info.product_descriptions;
    productDescriptionsAI.value = response.excel_info.product_descriptions_ai;

    // 初始化选中状态
    selectedItems.value = Array.from({ length: productDescriptions.value.length }).fill(false);

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

const isItemInAI = (index: number): boolean => {
  const item = productDescriptions.value[index];
  return productDescriptionsAI.value.some((aiItem) => JSON.stringify(aiItem) === JSON.stringify(item));
};

const selectAll = () => {
  selectedItems.value = selectedItems.value.map((_, index) => isItemInAI(index));
};

const deselectAll = () => {
  selectedItems.value = selectedItems.value.map(() => false);
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

.product-items {
  max-height: 600px;
  overflow-y: auto;
}

.product-item {
  margin-bottom: 12px;
  padding: 12px;
  border: 1px solid #e7e7e7;
  border-radius: 6px;
  background-color: #fff;
}

.product-item:hover {
  border-color: #0052d9;
  box-shadow: 0 2px 8px rgba(0, 82, 217, 0.1);
}

.product-content {
  margin-left: 8px;
}

.product-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.product-cell {
  padding: 4px 8px;
  background-color: #f5f5f5;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
}

.product-cell.ai-filtered {
  background-color: #ffebee;
  color: #d32f2f;
  text-decoration: line-through;
  opacity: 0.6;
}

/* 滚动条样式 */
.product-items::-webkit-scrollbar {
  width: 6px;
}

.product-items::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.product-items::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.product-items::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
