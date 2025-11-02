import { Controller, Get, HttpCode } from '@nestjs/common'
import { PrismaService } from 'src/prisma/prisma.service'

@Controller('/plans')
export class ListAllPlansController {
  constructor(private prisma: PrismaService) {}

  @Get()
  @HttpCode(200)
  async handle() {
    const plans = await this.prisma.plan.findMany({
      select: {
        id: true,
        name: true,
        price: true,
        download: true,
        upload: true,
        benefits: true,
      },
    })

    return { plans }
  }
}
