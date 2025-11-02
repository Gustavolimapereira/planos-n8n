import { Body, Controller, HttpCode, Post } from '@nestjs/common'
import { ZodValidationPipe } from 'src/pipes/zod-validation-pipe'
import { PrismaService } from 'src/prisma/prisma.service'
import z from 'zod'

const createPlanBodySchema = z.object({
  name: z.string(),

  price: z.number(),
  download: z.number(),
  upload: z.number(),
  benefits: z
    .array(
      z.object({
        id: z.string(), // <-- o ID vem do banco (Benefit.id)
      }),
    )
    .optional(),
  description: z.string().optional(),
})

const bodyValidationPipe = new ZodValidationPipe(createPlanBodySchema)
type CreatePlanBodySchema = z.infer<typeof createPlanBodySchema>

@Controller('/plans')
export class CreatePlanController {
  constructor(private prisma: PrismaService) {}

  @Post()
  @HttpCode(201)
  async handle(@Body(bodyValidationPipe) body: CreatePlanBodySchema) {
    const { name, price, download, upload, benefits, description } = body

    const plan = await this.prisma.plan.create({
      data: {
        name,
        price,
        download,
        upload,
        benefits: benefits
          ? {
              connect: benefits.map((b) => ({ id: b.id })),
            }
          : undefined,
        description,
      },
    })

    return { plan }
  }
}
