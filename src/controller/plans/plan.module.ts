import { Module } from '@nestjs/common'
import { PrismaService } from 'src/prisma/prisma.service'
import { CreatePlanController } from './create-plan.controller'
import { DeletePlanController } from './delete-plan.controller'
import { ListAllPlansController } from './listAll-plan.controller'
import { UpdatePlansController } from './update-plan.controller'

@Module({
  controllers: [
    CreatePlanController,
    DeletePlanController,
    ListAllPlansController,
    UpdatePlansController,
  ],
  providers: [PrismaService],
  exports: [],
})
export class PlanModule {}
