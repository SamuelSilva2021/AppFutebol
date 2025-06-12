import 'package:flutter/material.dart';
import 'package:futebol_wallace/models/jogador.dart';

class JogadorCard extends StatelessWidget {
  final Jogador jogador;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showOverallPosition;
  final Color? overallColor;
  final String? playerPosition;

  const JogadorCard({
    super.key,
    required this.jogador,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isSelected = false,
    this.onTap,
    this.showOverallPosition = false,
    this.overallColor,
    this.playerPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isSelected 
              ? colorScheme.primary 
              : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: isSelected ? LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
          ),
          child: Row(
            children: [
              // Avatar com inicial
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: _getOverallColor(colorScheme).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getOverallColor(colorScheme).withOpacity(0.3),
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    jogador.nome.isNotEmpty 
                        ? jogador.nome[0].toUpperCase() 
                        : '?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: _getOverallColor(colorScheme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16.0),
              
              // Informações do jogador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jogador.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    if (showOverallPosition)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16.0,
                            color: overallColor ?? _getOverallColor(colorScheme),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'Overall ${jogador.overall}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: overallColor ?? _getOverallColor(colorScheme),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (playerPosition != null) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: (overallColor ?? _getOverallColor(colorScheme)).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                playerPosition!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: overallColor ?? _getOverallColor(colorScheme),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (!showOverallPosition)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16.0,
                            color: _getOverallColor(colorScheme),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'Overall ${jogador.overall}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getOverallColor(colorScheme),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: _getOverallColor(colorScheme).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              _getOverallLabel(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getOverallColor(colorScheme),
                                fontWeight: FontWeight.w500,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // Ações (se habilitadas)
              if (showActions) ...[
                const SizedBox(width: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_rounded,
                        color: colorScheme.primary,
                        size: 20.0,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      constraints: const BoxConstraints(
                        minWidth: 36.0,
                        minHeight: 36.0,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_rounded,
                        color: colorScheme.error,
                        size: 20.0,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      constraints: const BoxConstraints(
                        minWidth: 36.0,
                        minHeight: 36.0,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.error.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Indicador de seleção
              if (onTap != null && !showActions) ...[
                const SizedBox(width: 8.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colorScheme.primary 
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? colorScheme.primary 
                          : colorScheme.outline,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: isSelected 
                      ? Icon(
                          Icons.check,
                          color: colorScheme.onPrimary,
                          size: 16.0,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getOverallColor(ColorScheme colorScheme) {
    if (overallColor != null) return overallColor!;
    if (jogador.overall >= 90) return Colors.green;
    if (jogador.overall >= 80) return colorScheme.secondary;
    if (jogador.overall >= 70) return colorScheme.tertiary;
    if (jogador.overall >= 60) return colorScheme.primary;
    return colorScheme.error;
  }

  String _getOverallLabel() {
    if (jogador.overall >= 90) return 'Craque';
    if (jogador.overall >= 80) return 'Excelente';
    if (jogador.overall >= 70) return 'Bom';
    if (jogador.overall >= 60) return 'Médio';
    return 'Iniciante';
  }
}