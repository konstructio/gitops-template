import type { NextApiRequest, NextApiResponse } from 'next';

type Configs = {
  configOne: string;
  configTwo: string;
};

export default function handler(req: NextApiRequest, res: NextApiResponse<Configs>) {
  const { CONFIG_ONE = '', CONFIG_TWO = '' } = process.env;

  res.status(200).json({
    configOne: CONFIG_ONE,
    configTwo: CONFIG_TWO,
  });
}
