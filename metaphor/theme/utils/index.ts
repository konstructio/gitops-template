import { css } from 'styled-components';

export const textTruncate = (lineCount: number) => css`
  display: -webkit-box;
  line-clamp: ${lineCount};
  -webkit-line-clamp: ${lineCount};
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
`;
