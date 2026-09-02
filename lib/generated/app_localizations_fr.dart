// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get notesApp => 'Application de notes';

  @override
  String get notes => 'Notes';

  @override
  String get editNote => 'Modifier la note';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get title => 'Titre';

  @override
  String get content => 'Contenu';

  @override
  String get pickImage => 'Choisir une image';

  @override
  String get search => 'Rechercher...';

  @override
  String get noNotes => 'Aucune note';

  @override
  String get tasksToDo => 'Tâches à faire';

  @override
  String get all => 'Tout';

  @override
  String get pending => 'En attente';

  @override
  String get completed => 'Terminé';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get dueTime => 'Heure d\'échéance';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String get taskReminder => 'Rappel de tâche';

  @override
  String get settings => 'Paramètres';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get receiveNotifications =>
      'Recevoir des notifications pour les rappels de tâches';

  @override
  String get testNotification => 'Notification de test';

  @override
  String get sendTestNotification =>
      'Envoyer une notification de test pour vérifier les autorisations';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get confirmDelete =>
      'Êtes-vous sûr de vouloir supprimer cette tâche ?';

  @override
  String get titleAndDescriptionRequired =>
      'Le titre et la description sont requis';

  @override
  String taskDeleted(Object title) {
    return '$title supprimé';
  }

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';
}
