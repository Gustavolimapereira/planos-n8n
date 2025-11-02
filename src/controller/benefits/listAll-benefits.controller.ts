import { Controller, Get, HttpCode } from '@nestjs/common'
import { PrismaService } from 'src/prisma/prisma.service'

@Controller('/benefits')
export class ListAllBenefitsController {
  constructor(private prisma: PrismaService) {}

  @Get()
  @HttpCode(200)
  async handle() {
    const benefits = await this.prisma.benefit.findMany({
      select: {
        id: true,
        name: true,
      },
    })

    return { benefits }
  }
}
