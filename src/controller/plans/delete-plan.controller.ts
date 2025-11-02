import {
  Controller,
  Delete,
  HttpCode,
  NotFoundException,
  Param,
} from '@nestjs/common'
import { PrismaService } from 'src/prisma/prisma.service'

@Controller('/plans/:id')
export class DeletePlanController {
  constructor(private prisma: PrismaService) {}

  @Delete()
  @HttpCode(204)
  async handle(@Param('id') id: string) {
    const plan = await this.prisma.plan.findUnique({
      where: { id },
    })

    if (!plan) {
      throw new NotFoundException('Plano não encontrado')
    }

    await this.prisma.plan.delete({
      where: { id },
    })
  }
}
