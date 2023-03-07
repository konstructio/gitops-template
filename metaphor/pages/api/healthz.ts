import type { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse<boolean>) {
  // eslint-disable-next-line no-console
  console.log('Im healthy!');
  res.status(200).send(true);
}
