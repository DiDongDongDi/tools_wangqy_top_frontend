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
      </div>

      <div class="results-content">
        <div class="results-grid">
          <div class="result-group">
            <div class="result-title">
              <div class="title-content">
                <t-icon name="error-circle" class="icon-only" />
                <span>文本 A 多余行 ({{ onlyInA.length }} 行)</span>
              </div>
              <t-button size="small" theme="default" variant="outline" class="copy-btn" @click="copyTextA">
                复制
              </t-button>
            </div>
            <t-textarea
              :value="onlyInAText"
              readonly
              :autosize="{ minRows: 6, maxRows: 12 }"
              class="result-textarea"
              placeholder="无多余行"
            />
          </div>

          <div class="result-group">
            <div class="result-title">
              <div class="title-content">
                <t-icon name="check-circle" class="icon-common" />
                <span>文本 AB 公共行 ({{ commonLines.length }} 行)</span>
              </div>
              <t-button size="small" theme="default" variant="outline" class="copy-btn" @click="copyCommon">
                复制
              </t-button>
            </div>
            <t-textarea
              :value="commonLinesText"
              readonly
              :autosize="{ minRows: 6, maxRows: 12 }"
              class="result-textarea common"
              placeholder="无公共行"
            />
          </div>

          <div class="result-group">
            <div class="result-title">
              <div class="title-content">
                <t-icon name="error-circle" class="icon-only" />
                <span>文本 B 多余行 ({{ onlyInB.length }} 行)</span>
              </div>
              <t-button size="small" theme="default" variant="outline" class="copy-btn" @click="copyTextB">
                复制
              </t-button>
            </div>
            <t-textarea
              :value="onlyInBText"
              readonly
              :autosize="{ minRows: 6, maxRows: 12 }"
              class="result-textarea"
              placeholder="无多余行"
            />
          </div>
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

// 格式化结果文本
const onlyInAText = computed(() => {
  return onlyInA.value.length > 0 ? onlyInA.value.join('\n') : '';
});

const onlyInBText = computed(() => {
  return onlyInB.value.length > 0 ? onlyInB.value.join('\n') : '';
});

const commonLinesText = computed(() => {
  return commonLines.value.length > 0 ? commonLines.value.join('\n') : '';
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

// 复制文本A
const copyTextA = async () => {
  try {
    await navigator.clipboard.writeText(onlyInAText.value);
    MessagePlugin.success('文本 A 多余行已复制到剪贴板');
  } catch (error) {
    MessagePlugin.error('复制失败');
    console.error('Copy error:', error);
  }
};

// 复制文本B
const copyTextB = async () => {
  try {
    await navigator.clipboard.writeText(onlyInBText.value);
    MessagePlugin.success('文本 B 多余行已复制到剪贴板');
  } catch (error) {
    MessagePlugin.error('复制失败');
    console.error('Copy error:', error);
  }
};

// 复制公共行
const copyCommon = async () => {
  try {
    await navigator.clipboard.writeText(commonLinesText.value);
    MessagePlugin.success('文本 AB 公共行已复制到剪贴板');
  } catch (error) {
    MessagePlugin.error('复制失败');
    console.error('Copy error:', error);
  }
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

.results-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 20px;
}

.result-group {
  display: flex;
  flex-direction: column;
}

.result-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
  font-weight: 600;
  color: var(--td-text-color-primary);
}

.result-title .t-icon {
  margin-right: 8px;
  font-size: 16px;
}

.result-title .title-content {
  display: flex;
  align-items: center;
  flex: 1;
}

.icon-only {
  color: var(--td-error-color);
}

.icon-common {
  color: var(--td-success-color);
}

.result-textarea {
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 14px;
  line-height: 1.4;
  background-color: var(--td-bg-color-page);
  border: 1px solid var(--td-border-level-1-color);
  border-radius: 6px;
  resize: none;
}

.result-textarea.common {
  background-color: var(--td-success-color-light);
  border-color: var(--td-success-color);
  color: var(--td-success-color);
}

.result-textarea:focus {
  border-color: var(--td-brand-color);
}

.copy-btn {
  margin-left: auto;
}

@media (max-width: 1024px) {
  .results-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
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

  .results-content {
    padding: 16px;
  }
}
</style>
