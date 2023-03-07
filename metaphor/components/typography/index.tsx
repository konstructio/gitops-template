import React, { FunctionComponent } from 'react';
import { Typography as TypographyMUI, TypographyProps } from '@mui/material';

export type Variant =
  | 'h1'
  | 'h2'
  | 'h3'
  | 'h4'
  | 'h5'
  | 'h6'
  | 'subtitle1'
  | 'subtitle2'
  | 'subtitle3'
  | 'labelLarge'
  | 'labelMedium'
  | 'labelSmall'
  | 'buttonSmall'
  | 'body1'
  | 'body2'
  | 'body3'
  | 'tooltip';

export interface ITypographyProps {
  variant: Variant | string;
  children: React.ReactNode;
}

const Typography: FunctionComponent<TypographyProps> = ({ variant, ...props }) => {
  return <TypographyMUI variant={variant as Variant} {...props} />;
};

export default Typography;

// Update the Typography's variant prop options
declare module '@mui/material/Typography' {
  interface TypographyPropsVariantOverrides {
    h1: true;
    h2: true;
    h3: true;
    h4: true;
    h5: true;
    h6: true;
    subtitle1: true;
    subtitle2: true;
    subtitle3: true;
    labelLarge: true;
    labelMedium: true;
    labelSmall: true;
    buttonSmall: true;
    body1: true;
    body2: true;
    body3: true;
    tooltip: true;
    caption: false;
    button: false;
    overline: false;
  }
}
