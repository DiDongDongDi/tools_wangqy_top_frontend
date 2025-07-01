import { FileIcon } from 'tdesign-icons-vue-next';
import { shallowRef } from 'vue';

import Layout from '@/layouts/index.vue';

export default [
  {
    path: '/excel-tools',
    component: Layout,
    redirect: '/excel-tools/product-description',
    name: 'excel-tools',
    meta: {
      title: {
        zh_CN: 'Excel处理',
        en_US: 'Excel Tools',
      },
      icon: shallowRef(FileIcon),
      orderNo: 1,
    },
    children: [
      {
        path: 'product-description',
        name: 'ProductDescription',
        component: () => import('@/pages/excel-tools/product-description/index.vue'),
        meta: {
          title: {
            zh_CN: '产品描述',
            en_US: 'Product Description',
          },
        },
      },
    ],
  },
];
