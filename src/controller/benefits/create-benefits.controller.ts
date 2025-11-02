import { Body, Controller, HttpCode, Post } from '@nestjs/common'
import { ZodValidationPipe } from 'src/pipes/zod-validation-pipe'
import { PrismaService } from 'src/prisma/prisma.service'
import z from 'zod'

const createBenefitsBodySchema = z.object({
  name: z.string(),
})

const bodyValidationPipe = new ZodValidationPipe(createBenefitsBodySchema)
type CreateBenefitsBodySchema = z.infer<typeof createBenefitsBodySchema>

@Controller('/benefits')
export class CreateBenefitController {
  constructor(private prisma: PrismaService) {}

  @Post()
  @HttpCode(201)
  async handle(@Body(bodyValidationPipe) body: CreateBenefitsBodySchema) {
    const { name } = body

    const plan = await this.prisma.benefit.create({
      data: {
        name,
      },
    })

    return { plan }
  }
}
