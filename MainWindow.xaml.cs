using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Windows;

namespace HairSalonApp
{
    public partial class MainWindow : Window
    {
        private string connectionString = "Server=localhost\\SQLEXPRESS;Database=LABA   ;Integrated Security=True;";


        public MainWindow()
        {
            InitializeComponent();
            RefreshRecords();
            RefreshStrizhkaRecords();
        }

        // Метод для добавления клиента в базу данных
        private void AddClientToDatabase_Click(object sender, RoutedEventArgs e)
        {
            string idText = ClientIDTextBox.Text.Trim();
            string name = ClientNameTextBox.Text.Trim();
            string phone = ClientPhoneTextBox.Text.Trim();
            string visitsText = ClientVisitsTextBox.Text.Trim();
            DateTime? date = ClientDatePicker.SelectedDate;

            // Валидация введенных данных
            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(phone) || string.IsNullOrEmpty(visitsText) || date == null)
            {
                MessageBox.Show("Пожалуйста, заполните все поля.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            if (!int.TryParse(idText, out int clientId))
            {
                MessageBox.Show("ID клиента должен быть числом.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            if (!int.TryParse(visitsText, out int visits) || visits <= 0 || visits >= 10000)
            {
                MessageBox.Show("Количество посещений должно быть числом от 1 до 9999.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    string insertQuery = "INSERT INTO KLIENT (IDklient, FIO, KOLICHPOSESH, Telefon, DATAZAPIS) " +
                                         "VALUES (@IDklient, @FIO, @KOLICHPOSESH, @Telefon, @DATAZAPIS)";

                    using (var command = new SqlCommand(insertQuery, connection))
                    {
                        command.Parameters.AddWithValue("@IDklient", clientId);
                        command.Parameters.AddWithValue("@FIO", name);
                        command.Parameters.AddWithValue("@KOLICHPOSESH", visits);
                        command.Parameters.AddWithValue("@Telefon", phone);
                        command.Parameters.AddWithValue("@DATAZAPIS", date.Value);
                        command.ExecuteNonQuery();
                    }
                }
                MessageBox.Show("Клиент успешно добавлен.", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                ClearInputFields();
                RefreshRecords();
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка при добавлении клиента:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}", "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Метод для удаления клиента из базы данных
        private void DeleteClientFromDatabase_Click(object sender, RoutedEventArgs e)
        {
            if (RecordsListView.SelectedItem is Client selectedClient)
            {
                var result = MessageBox.Show($"Вы уверены, что хотите удалить клиента: {selectedClient.FIO}?",
                                             "Подтверждение удаления",
                                             MessageBoxButton.YesNo,
                                             MessageBoxImage.Question);
                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        using (var connection = new SqlConnection(connectionString))
                        {
                            connection.Open();
                            string deleteQuery = "DELETE FROM KLIENT WHERE IDklient = @IDklient";
                            using (var command = new SqlCommand(deleteQuery, connection))
                            {
                                command.Parameters.AddWithValue("@IDklient", selectedClient.IDklient);
                                command.ExecuteNonQuery();
                            }
                        }
                        MessageBox.Show("Клиент успешно удален.", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                        RefreshRecords();
                    }
                    catch (SqlException ex)
                    {
                        MessageBox.Show($"Ошибка при удалении клиента:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}", "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show("Пожалуйста, выберите клиента для удаления.", "Информация", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        // Метод для обновления списка клиентов
        private void RefreshRecords_Click(object sender, RoutedEventArgs e)
        {
            RefreshRecords();
        }

        private void RefreshRecords()
        {
            var clients = new List<Client>();

            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    string selectQuery = "SELECT IDklient, FIO, KOLICHPOSESH, Telefon, DATAZAPIS FROM KLIENT";

                    using (var command = new SqlCommand(selectQuery, connection))
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            clients.Add(new Client
                            {
                                IDklient = reader.GetInt32(0),
                                FIO = reader.GetString(1),
                                KOLICHPOSESH = reader.GetInt32(2),
                                Telefon = reader.GetString(3),
                                DATAZAPIS = reader.GetDateTime(4)
                            });
                        }
                    }
                }

                RecordsListView.ItemsSource = clients; // Обновляем отображение на интерфейсе
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка при загрузке данных:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}",
                                "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UpdateClientInDatabase(int clientId, string name, int visits, string phone, DateTime date)
        {
            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    string updateQuery = "UPDATE KLIENT SET FIO = @FIO, KOLICHPOSESH = @KOLICHPOSESH, Telefon = @Telefon, DATAZAPIS = @DATAZAPIS " +
                                         "WHERE IDklient = @IDklient";

                    using (var command = new SqlCommand(updateQuery, connection))
                    {
                        command.Parameters.AddWithValue("@IDklient", clientId);
                        command.Parameters.AddWithValue("@FIO", name);
                        command.Parameters.AddWithValue("@KOLICHPOSESH", visits);
                        command.Parameters.AddWithValue("@Telefon", phone);
                        command.Parameters.AddWithValue("@DATAZAPIS", date);

                        int rowsAffected = command.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            MessageBox.Show("Данные клиента успешно обновлены.", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                            RefreshRecords(); // Обновляем список после обновления записи
                        }
                        else
                        {
                            MessageBox.Show("Клиент с указанным ID не найден.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка обновления данных клиента:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}",
                                "Ошибка базы данных", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void UpdateClientButton_Click(object sender, RoutedEventArgs e)
        {
            if (int.TryParse(ClientIDTextBox.Text, out int clientId) &&
                int.TryParse(ClientVisitsTextBox.Text, out int visits) &&
                ClientDatePicker.SelectedDate != null)
            {
                string name = ClientNameTextBox.Text;
                string phone = ClientPhoneTextBox.Text;
                DateTime date = ClientDatePicker.SelectedDate.Value;

                UpdateClientInDatabase(clientId, name, visits, phone, date);
            }
            else
            {
                MessageBox.Show("Пожалуйста, заполните корректно все поля.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        // Метод для очистки полей ввода после добавления клиента
        private void ClearInputFields()
        {
            ClientIDTextBox.Text = string.Empty;
            ClientNameTextBox.Text = string.Empty;
            ClientPhoneTextBox.Text = string.Empty;
            ClientVisitsTextBox.Text = string.Empty;
            ClientDatePicker.SelectedDate = null;
        }


        // Метод для добавления стрижки в базу данных
        private void AddStrizhka_Click(object sender, RoutedEventArgs e)
        {
            string idText = StrizhkaIDTextBox.Text.Trim();
            string name = StrizhkaNameTextBox.Text.Trim();
            string complexity = StrizhkaSlozhnostComboBox.Text.Trim();
            string typeText = StrizhkaTypeTextBox.Text.Trim();
            string gender = StrizhkaGenderComboBox.Text.Trim();

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(complexity) || string.IsNullOrEmpty(typeText) || string.IsNullOrEmpty(gender))
            {
                MessageBox.Show("Пожалуйста, заполните все поля для стрижки.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            if (!int.TryParse(idText, out int haircutId) || !int.TryParse(typeText, out int typeId))
            {
                MessageBox.Show("ID и Тип должны быть числовыми.", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    string insertQuery = "INSERT INTO STRIZHKA (IDSTRIZH, NAZV, SLOZHNOST, IDTIPSTRIZH, POL) " +
                                         "VALUES (@IDSTRIZH, @NAZV, @SLOZHNOST, @IDTIPSTRIZH, @POL)";

                    using (var command = new SqlCommand(insertQuery, connection))
                    {
                        command.Parameters.AddWithValue("@IDSTRIZH", haircutId);
                        command.Parameters.AddWithValue("@NAZV", name);
                        command.Parameters.AddWithValue("@SLOZHNOST", complexity);
                        command.Parameters.AddWithValue("@IDTIPSTRIZH", typeId);
                        command.Parameters.AddWithValue("@POL", gender); // предполагается, что пол - это 'М' или 'Ж'
                        command.ExecuteNonQuery();
                    }
                }
                MessageBox.Show("Стрижка успешно добавлена.", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                ClearHaircutInputFields();
                RefreshStrizhkaRecords();
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка при добавлении стрижки:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}", "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Метод для удаления стрижки из базы данных
        private void DeleteStrizhka_Click(object sender, RoutedEventArgs e)
        {
            if (StrizhkaListView.SelectedItem is Strizhka selectedHaircut)
            {
                var result = MessageBox.Show($"Вы уверены, что хотите удалить стрижку: {selectedHaircut.NAZV}?",
                                             "Подтверждение удаления",
                                             MessageBoxButton.YesNo,
                                             MessageBoxImage.Question);
                if (result == MessageBoxResult.Yes)
                {
                    try
                    {
                        using (var connection = new SqlConnection(connectionString))
                        {
                            connection.Open();
                            string deleteQuery = "DELETE FROM STRIZHKA WHERE IDSTRIZH = @IDSTRIZH";
                            using (var command = new SqlCommand(deleteQuery, connection))
                            {
                                command.Parameters.AddWithValue("@IDSTRIZH", selectedHaircut.IDSTRIZH);
                                command.ExecuteNonQuery();
                            }
                        }
                        MessageBox.Show("Стрижка успешно удалена.", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                        RefreshStrizhkaRecords();
                    }
                    catch (SqlException ex)
                    {
                        MessageBox.Show($"Ошибка при удалении стрижки:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}", "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show("Пожалуйста, выберите стрижку для удаления.", "Информация", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        // Метод для обновления списка стрижек
        private void RefreshStrizhkaRecords(object sender, RoutedEventArgs e)
        {
            RefreshStrizhkaRecords();
        }

        private void RefreshStrizhkaRecords()
        {
            var haircuts = new List<Strizhka>();

            try
            {
                using (var connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    string selectQuery = "SELECT IDSTRIZH, NAZV, SLOZHNOST, IDTIPSTRIZH, POL FROM STRIZHKA";
                    using (var command = new SqlCommand(selectQuery, connection))
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            haircuts.Add(new Strizhka
                            {
                                IDSTRIZH = reader.GetInt32(0),
                                NAZV = reader.GetString(1),
                                SLOZHNOST = reader.GetString(2),
                                IDTIPSTRIZH = reader.GetInt32(3),
                                POL = reader.GetString(4)
                            });
                        }
                    }
                }
                StrizhkaListView.ItemsSource = haircuts;
            }
            catch (SqlException ex)
            {
                MessageBox.Show($"Ошибка при загрузке данных стрижек:\nКод ошибки SQL: {ex.Number}\nСообщение: {ex.Message}", "Ошибка подключения к базе данных", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Неожиданная ошибка: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Метод для очистки полей ввода стрижки после добавления
        private void ClearHaircutInputFields()
        {
            StrizhkaIDTextBox.Text = string.Empty;
            StrizhkaNameTextBox.Text = string.Empty;
            StrizhkaSlozhnostComboBox.Text = string.Empty;
            StrizhkaTypeTextBox.Text = string.Empty;
            StrizhkaGenderComboBox.Text = string.Empty;
        }



    }

    // Класс модели клиента
    public class Client
    {
        public int IDklient { get; set; }
        public string FIO { get; set; } = string.Empty;  // Добавлено значение по умолчанию
        public int KOLICHPOSESH { get; set; }
        public string Telefon { get; set; } = string.Empty;  // Добавлено значение по умолчанию
        public DateTime DATAZAPIS { get; set; }
    }

    // Класс модели стрижки
    public class Strizhka
    {
        public int IDSTRIZH { get; set; }
        public string NAZV { get; set; } = string.Empty;
        public string SLOZHNOST { get; set; } = string.Empty;
        public int IDTIPSTRIZH { get; set; }
        public string POL { get; set; } = string.Empty;
    }
}
