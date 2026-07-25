import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Contrato de plataforma (PLATFORM.md §3):
  //  - El puerto se lee de PORT y por defecto es 3000.
  //  - Se escucha en 0.0.0.0, NO en localhost: dentro de un pod, un proceso
  //    atado a 127.0.0.1 es inalcanzable desde el kubelet (probes) y desde el
  //    Service. Síntoma engañoso: el log dice "listening" y las probes fallan
  //    con "connection refused".
  await app.listen(Number(process.env.PORT ?? 3000), '0.0.0.0');
}
void bootstrap();
