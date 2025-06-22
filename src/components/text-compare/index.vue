<template>
  <div class="text-compare-container">
    <div class="text-compare-header">
      <h2>文本比较工具</h2>
      <p>比较两段文本的差异，按行分析并显示独有和公共内容</p>
    </div>

    <div class="text-input-section">
      <div class="text-input-group">
        <div class="input-header">
          <h3>文本 A</h3>
          <t-button size="small" theme="danger" variant="outline" @click="clearTextA"> 清空输入 </t-button>
        </div>
        <t-textarea
          v-model="textA"
          placeholder="请输入第一段文本..."
          :autosize="{ minRows: 8, maxRows: 15 }"
          class="text-input"
        />
      </div>

      <div class="text-input-group">
        <div class="input-header">
          <h3>文本 B</h3>
          <t-button size="small" theme="danger" variant="outline" @click="clearTextB"> 清空输入 </t-button>
        </div>
        <t-textarea
          v-model="textB"
          placeholder="请输入第二段文本..."
          :autosize="{ minRows: 8, maxRows: 15 }"
          class="text-input"
        />
      </div>
    </div>

    <div class="action-section">
      <t-button theme="primary" size="large" :loading="isComparing" @click="compareTexts"> 计算文本行差异 </t-button>
    </div>

    <div v-if="hasResults" class="results-section">
      <div class="results-header">
        <h3>比较结果</h3>
        <t-button size="small" theme="default" variant="outline" @click="copyResults"> 复制结果 </t-button>
      </div>

      <div class="results-content">
        <div class="result-group">
          <div class="result-title">
            <t-icon name="error-circle" class="icon-only" />
            <span>文本 A 多余行 ({{ onlyInA.length }} 行)</span>
          </div>
          <div v-if="onlyInA.length > 0" class="result-list">
            <div v-for="(line, index) in onlyInA" :key="`a-${index}`" class="result-item">
              {{ line }}
            </div>
          </div>
          <div v-else class="result-empty">无多余行</div>
        </div>

        <div class="result-group">
          <div class="result-title">
            <t-icon name="check-circle" class="icon-common" />
            <span>文本 AB 公共行 ({{ commonLines.length }} 行)</span>
          </div>
          <div v-if="commonLines.length > 0" class="result-list">
            <div v-for="(line, index) in commonLines" :key="`common-${index}`" class="result-item common">
              {{ line }}
            </div>
          </div>
          <div v-else class="result-empty">无公共行</div>
        </div>

        <div class="result-group">
          <div class="result-title">
            <t-icon name="error-circle" class="icon-only" />
            <span>文本 B 多余行 ({{ onlyInB.length }} 行)</span>
          </div>
          <div v-if="onlyInB.length > 0" class="result-list">
            <div v-for="(line, index) in onlyInB" :key="`b-${index}`" class="result-item">
              {{ line }}
            </div>
          </div>
          <div v-else class="result-empty">无多余行</div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { MessagePlugin } from 'tdesign-vue-next';
import { computed, ref } from 'vue';

defineOptions({
  name: 'TextCompare',
});

const textA = ref('');
const textB = ref('');
const isComparing = ref(false);

// 比较结果
const onlyInA = ref<string[]>([]);
const onlyInB = ref<string[]>([]);
const commonLines = ref<string[]>([]);

// 计算属性
const hasResults = computed(() => {
  return onlyInA.value.length > 0 || onlyInB.value.length > 0 || commonLines.value.length > 0;
});

// 清空文本A
const clearTextA = () => {
  textA.value = '';
  clearResults();
};

// 清空文本B
const clearTextB = () => {
  textB.value = '';
  clearResults();
};

// 清空结果
const clearResults = () => {
  onlyInA.value = [];
  onlyInB.value = [];
  commonLines.value = [];
};

// 比较文本
const compareTexts = () => {
  if (!textA.value.trim() && !textB.value.trim()) {
    MessagePlugin.warning('请至少输入一段文本进行比较');
    return;
  }

  isComparing.value = true;

  // 模拟异步处理
  setTimeout(() => {
    try {
      // 按行分割并过滤空行
      const linesA = textA.value.split('\n').filter((line) => line.trim() !== '');
      const linesB = textB.value.split('\n').filter((line) => line.trim() !== '');

      // 创建Set用于快速查找
      const setA = new Set(linesA);
      const setB = new Set(linesB);

      // 计算差异
      onlyInA.value = linesA.filter((line) => !setB.has(line));
      onlyInB.value = linesB.filter((line) => !setA.has(line));
      commonLines.value = linesA.filter((line) => setB.has(line));

      MessagePlugin.success('文本比较完成');
    } catch (error) {
      MessagePlugin.error('比较过程中出现错误');
      console.error('Text comparison error:', error);
    } finally {
      isComparing.value = false;
    }
  }, 500);
};

// 复制结果
const copyResults = async () => {
  try {
    const resultText = generateResultText();
    await navigator.clipboard.writeText(resultText);
    MessagePlugin.success('结果已复制到剪贴板');
  } catch (error) {
    MessagePlugin.error('复制失败');
    console.error('Copy error:', error);
  }
};

// 生成结果文本
const generateResultText = () => {
  let result = '=== 文本比较结果 ===\n\n';

  result += `文本 A 多余行 (${onlyInA.value.length} 行):\n`;
  if (onlyInA.value.length > 0) {
    onlyInA.value.forEach((line) => {
      result += `- ${line}\n`;
    });
  } else {
    result += '无多余行\n';
  }

  result += `\n文本 AB 公共行 (${commonLines.value.length} 行):\n`;
  if (commonLines.value.length > 0) {
    commonLines.value.forEach((line) => {
      result += `- ${line}\n`;
    });
  } else {
    result += '无公共行\n';
  }

  result += `\n文本 B 多余行 (${onlyInB.value.length} 行):\n`;
  if (onlyInB.value.length > 0) {
    onlyInB.value.forEach((line) => {
      result += `- ${line}\n`;
    });
  } else {
    result += '无多余行\n';
  }

  return result;
};
</script>
<style scoped>
.text-compare-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}

.text-compare-header {
  text-align: center;
  margin-bottom: 32px;
}

.text-compare-header h2 {
  margin: 0 0 8px 0;
  color: var(--td-text-color-primary);
}

.text-compare-header p {
  margin: 0;
  color: var(--td-text-color-secondary);
}

.text-input-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 24px;
}

.text-input-group {
  display: flex;
  flex-direction: column;
}

.input-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.input-header h3 {
  margin: 0;
  color: var(--td-text-color-primary);
}

.text-input {
  flex: 1;
}

.action-section {
  text-align: center;
  margin-bottom: 32px;
}

.results-section {
  border: 1px solid var(--td-border-level-1-color);
  border-radius: 8px;
  overflow: hidden;
}

.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background-color: var(--td-bg-color-container);
  border-bottom: 1px solid var(--td-border-level-1-color);
}

.results-header h3 {
  margin: 0;
  color: var(--td-text-color-primary);
}

.results-content {
  padding: 20px;
}

.result-group {
  margin-bottom: 24px;
}

.result-group:last-child {
  margin-bottom: 0;
}

.result-title {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  font-weight: 600;
  color: var(--td-text-color-primary);
}

.result-title .t-icon {
  margin-right: 8px;
  font-size: 16px;
}

.icon-only {
  color: var(--td-error-color);
}

.icon-common {
  color: var(--td-success-color);
}

.result-list {
  background-color: var(--td-bg-color-page);
  border: 1px solid var(--td-border-level-1-color);
  border-radius: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.result-item {
  padding: 8px 12px;
  border-bottom: 1px solid var(--td-border-level-1-color);
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 14px;
  line-height: 1.4;
  word-break: break-all;
}

.result-item:last-child {
  border-bottom: none;
}

.result-item.common {
  background-color: var(--td-success-color-light);
  color: var(--td-success-color);
}

.result-empty {
  padding: 16px;
  text-align: center;
  color: var(--td-text-color-placeholder);
  background-color: var(--td-bg-color-page);
  border: 1px solid var(--td-border-level-1-color);
  border-radius: 6px;
}

@media (max-width: 768px) {
  .text-input-section {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .text-compare-container {
    padding: 16px;
  }

  .results-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}
</style>
