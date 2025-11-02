import { Module } from '@nestjs/common'
import { PlanModule } from './controller/plans/plan.module'
import { BenefitModule } from './controller/benefits/plan.module'

@Module({
  imports: [PlanModule, BenefitModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
