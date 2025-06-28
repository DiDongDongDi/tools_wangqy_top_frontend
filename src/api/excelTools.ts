import type { UploadResponse } from '@/api/model/excelToolsModel';
import { request } from '@/utils/request';

const Api = {
  FileUpload: '/api/excel-tools/file/upload',
};

export function uploadExcelFile(file: File) {
  const formData = new FormData();
  formData.append('file', file);

  return request.post<UploadResponse>({
    url: Api.FileUpload,
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
}
