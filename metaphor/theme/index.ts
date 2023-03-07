import { DefaultTheme } from 'styled-components';
export interface ITheme extends DefaultTheme {
  colors: {
    americanGreen: string;
    athenaBlue: string;
    beluga: string;
    black: string;
    bleachedSilk: string;
    caribeanSea: string;
    chineseOrange: string;
    danger: string;
    dawnDeparts: string;
    ferntastic: string;
    gravelFint: string;
    gray: string;
    greenJelly: string;
    naivePeach: string;
    purpleCabbage: string;
    stomyShower: string;
    transparentBlue: string;
    ultimateGrey: string;
    yellowOrange: string;
    white: string;

    // Kubefirst color palette
    americanBlue: string;
    childOfLight: string;
    moonlessMystery: string;
    jordyBlue: string;
    primary: string;
    saltboxBlue: string;
    volcanicSand: string;
    washMe: string;
    whiteSmoke: string;
  };
}

const theme: ITheme = {
  colors: {
    americanBlue: '#3C356C',
    americanGreen: '#3CB53A',
    athenaBlue: '#61DAFB',
    beluga: '#F1F1F1',
    black: '#000000',
    bleachedSilk: '#F2F2F2',
    caribeanSea: '#007D9C',
    childOfLight: '#F1F5F9',
    chineseOrange: '#F06F3C',
    danger: '#DC2626',
    dawnDeparts: '#CCF8FE',
    ferntastic: '#75AD64',
    gravelFint: '#BBBBBB',
    gray: 'gray',
    greenJelly: '#2E9485',
    jordyBlue: '#7AA5E2',
    moonlessMystery: '#1E2235',
    naivePeach: '#FDE5D2',
    primary: '#8851C8',
    purpleCabbage: '#3636A1',
    saltboxBlue: '#64748B',
    stomyShower: '#0487AF',
    transparentBlue: '#DAD7FE',
    ultimateGrey: '#A9A9A9',
    yellowOrange: '#FAB203',
    volcanicSand: '#3F3F46',
    washMe: '#F8FAFC',
    white: '#FFFFFF',
    whiteSmoke: '#F5F5F5',
  },
};

export default theme;
