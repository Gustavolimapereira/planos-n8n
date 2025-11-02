/*
  Warnings:

  - Added the required column `description` to the `Plan` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Plan" ADD COLUMN     "description" TEXT NOT NULL;
