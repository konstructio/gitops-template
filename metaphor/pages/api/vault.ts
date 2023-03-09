import type { NextApiRequest, NextApiResponse } from 'next';

type Configs = {
  secretOne: string;
  secretTwo: string;
};

export default function handler(req: NextApiRequest, res: NextApiResponse<Configs>) {
  const { SECRET_ONE = '', SECRET_TWO = '' } = process.env;

  res.status(200).json({
    secretOne: SECRET_ONE,
    secretTwo: SECRET_TWO,
  });
}
