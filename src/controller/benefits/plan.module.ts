import { Module } from '@nestjs/common'
import { PrismaService } from 'src/prisma/prisma.service'
import { CreateBenefitController } from './create-benefits.controller'
import { ListAllBenefitsController } from './listAll-benefits.controller'

@Module({
  controllers: [CreateBenefitController, ListAllBenefitsController],
  providers: [PrismaService],
  exports: [],
})
export class BenefitModule {}
