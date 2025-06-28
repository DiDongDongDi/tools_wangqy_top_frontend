export interface ExcelInfo {
  total_rows: number;
  total_columns: number;
  product_descriptions: string[][];
  product_descriptions_ai: string[][];
}

export interface FileInfo {
  file_name: string;
  file_size: number;
  excel_info: ExcelInfo;
}

export interface UploadResponse {
  success: boolean;
  message: string;
  file_name: string;
  file_size: number;
  excel_info: ExcelInfo;
}
