import { Controller, Get } from '@nestjs/common';

/**
 * Healthcheck de plataforma (PLATFORM.md §4).
 *
 * Contrato: GET /health devuelve 200 y un cuerpo JSON. No debe depender de
 * ninguna dependencia externa (base de datos, otro servicio): esta ruta la
 * usan readiness Y liveness. Si /health comprueba la base de datos, una caída
 * de la base de datos hace que el kubelet reinicie el pod en bucle — un fallo
 * ajeno se convierte en un CrashLoopBackOff propio.
 *
 * Si hace falta una comprobación profunda, va en OTRA ruta (/health/deep) y
 * NO se ata a liveness.
 */
@Controller('health')
export class HealthController {
  @Get()
  check(): { status: string; app: string; environment: string } {
    return {
      status: 'ok',
      app: process.env.APP_NAME ?? 'nestjs-api',
      environment: process.env.APP_ENV ?? 'unknown',
    };
  }
}
