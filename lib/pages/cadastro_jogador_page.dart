import 'package:flutter/material.dart';
import 'package:futebol_wallace/models/jogador.dart';
import 'package:futebol_wallace/services/jogador_service.dart';

class CadastroJogadorPage extends StatefulWidget {
  final Jogador? jogador;
  
  const CadastroJogadorPage({
    super.key,
    this.jogador,
  });

  @override
  State<CadastroJogadorPage> createState() => _CadastroJogadorPageState();
}

class _CadastroJogadorPageState extends State<CadastroJogadorPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  double _overall = 75.0;
  bool _isLoading = false;
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool get _isEditing => widget.jogador != null;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    if (_isEditing) {
      _nomeController.text = widget.jogador!.nome;
      _overall = widget.jogador!.overall.toDouble();
    }
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Jogador' : 'Cadastrar Jogador',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.secondary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isEditing ? Icons.edit : Icons.person_add,
                          size: 48.0,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _isEditing ? 'Atualizar Informações' : 'Novo Jogador',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _isEditing 
                            ? 'Modifique os dados do jogador abaixo'
                            : 'Preencha os dados para adicionar um novo jogador',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32.0),
                
                // Nome Field
                Text(
                  'Nome do Jogador',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    hintText: 'Digite o nome completo',
                    prefixIcon: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do jogador';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32.0),
                
                // Overall Section
                Text(
                  'Overall do Jogador',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16.0),
                
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Habilidade',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: _getOverallColor().withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${_overall.round()}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getOverallColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _getOverallColor(),
                          inactiveTrackColor: colorScheme.outline.withOpacity(0.2),
                          thumbColor: _getOverallColor(),
                          overlayColor: _getOverallColor().withOpacity(0.2),
                          trackHeight: 6.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12.0,
                          ),
                        ),
                        child: Slider(
                          value: _overall,
                          min: 50.0,
                          max: 99.0,
                          divisions: 49,
                          onChanged: (value) => setState(() => _overall = value),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '50',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            _getOverallLabel(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _getOverallColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '99',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40.0),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          side: BorderSide(
                            color: colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarJogador,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditing ? 'Atualizar' : 'Cadastrar',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getOverallColor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_overall >= 90) return Colors.green;
    if (_overall >= 80) return colorScheme.secondary;
    if (_overall >= 70) return colorScheme.tertiary;
    return colorScheme.error;
  }

  String _getOverallLabel() {
    if (_overall >= 90) return 'Craque';
    if (_overall >= 80) return 'Maestro';
    if (_overall >= 70) return 'Bom';
    if (_overall >= 60) return 'Regular';
    return 'Iniciante';
  }

  Future<void> _salvarJogador() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nome = _nomeController.text.trim();
      
      // Verificar se já existe jogador com esse nome
      final existeNome = await JogadorService.existeJogadorComNome(
        nome, 
        excludeId: widget.jogador?.id,
      );
      
      if (existeNome) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Já existe um jogador com o nome \"$nome\"'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (_isEditing) {
        final jogadorAtualizado = widget.jogador!.copyWith(
          nome: nome,
          overall: _overall.round(),
        );
        await JogadorService.updateJogador(jogadorAtualizado);
      } else {
        final novoJogador = Jogador(
          nome: nome,
          overall: _overall.round(),
        );
        await JogadorService.addJogador(novoJogador);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Jogador atualizado com sucesso!' 
                  : 'Jogador cadastrado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} jogador: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}