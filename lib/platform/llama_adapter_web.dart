class LlamaService {
  Future<void> init(String modelPath, {ModelParams? modelParams}) =>
      Future<void>.error(UnsupportedError('Local AI is unavailable on Web.'));

  Future<String> applyChatTemplate(List<LlamaChatMessage> messages) async => '';

  Stream<String> generate(String prompt, {GenerationParams? params}) =>
      Stream<String>.error(UnsupportedError('Local AI is unavailable on Web.'));

  void dispose() {}
}

class LlamaChatMessage {
  const LlamaChatMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class ModelParams {
  const ModelParams({this.contextSize, this.gpuLayers, this.preferredBackend});

  final int? contextSize;
  final int? gpuLayers;
  final GpuBackend? preferredBackend;
}

enum GpuBackend { auto, metal }

class GenerationParams {
  const GenerationParams({this.maxTokens, this.temp});

  final int? maxTokens;
  final double? temp;
}
