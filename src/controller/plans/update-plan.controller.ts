import {
  Body,
  Controller,
  HttpCode,
  NotFoundException,
  Param,
  Put,
} from '@nestjs/common'
import { ZodValidationPipe } from 'src/pipes/zod-validation-pipe'
import { PrismaService } from 'src/prisma/prisma.service'
import z from 'zod'

const updatePlanBodySchema = z.object({
  name: z.string().optional(),
  price: z.number().optional(),
  download: z.number().optional(),
  upload: z.number().optional(),
  benefits: z.array(z.string()).optional(),
})

const bodyValidationPipe = new ZodValidationPipe(updatePlanBodySchema)
type UpdatePlanBodySchema = z.infer<typeof updatePlanBodySchema>

@Controller('/plans/:id')
export class UpdatePlansController {
  constructor(private prisma: PrismaService) {}

  @Put()
  @HttpCode(200)
  async handle(
    @Param('id') id: string,
    @Body(bodyValidationPipe) body: UpdatePlanBodySchema,
  ) {
    const { name, price, download, upload, benefits } = body

    const plan = await this.prisma.plan.findUnique({
      where: { id },
    })

    if (!plan) {
      throw new NotFoundException('Plano não encontrado')
    }

    const planUpdate = await this.prisma.plan.update({
      where: { id },
      data: {
        name,
        price,
        download,
        upload,
        ...(benefits
          ? {
              benefits: {
                // cria benefícios novos (você pode trocar para `connectOrCreate` se quiser evitar duplicados)
                create: benefits.map((b) => ({ name: b })),
              },
            }
          : {}),
      },
      include: {
        benefits: true,
      },
    })

    return {
      planUpdate,
    }
  }
}
