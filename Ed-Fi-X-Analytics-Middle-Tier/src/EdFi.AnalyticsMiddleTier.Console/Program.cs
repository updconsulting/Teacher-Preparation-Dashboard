using CommandLine;
using EdFi.AnalyticsMiddleTier.Lib;
using System;
using System.Collections.Generic;

namespace EdFi.AnalyticsMiddleTier.Console
{
    internal class Program
    {
        internal static void Main(string[] args)
        {
            Parser.Default
                .ParseArguments<Options>(args)
                .WithParsed(RunWithOptions)
                .WithNotParsed(WriteArgumentErrorMessage);


            void RunWithOptions(Options options)
            {
                bool successful;
                var message = string.Empty;

                if (options.Uninstall)
                {
                    (successful, message) = Uninstall.Run(options.ConnectionString);
                }
                else
                {
                    (successful, message) = MigrationUtility.Run(options.ConnectionString, options.IncludeIndexes, options.IncludeViews);
                }

                if (!successful)
                {
#if DEBUG
                    System.Console.WriteLine(string.Empty);
                    System.Console.WriteLine(message);
                    System.Console.WriteLine(string.Empty);
                    System.Console.WriteLine("Press any key to continue...");
                    System.Console.ReadKey();
#endif
                    Environment.ExitCode = -2;
                }
                else
                {
                    System.Console.WriteLine("Success!");
                }

                Environment.ExitCode = 0;
            }

            void WriteArgumentErrorMessage(IEnumerable<Error> errors)
            {
                Environment.ExitCode = -1;
            }
        }
    }

    internal class Options
    {
        [Option('c', "connectionString", Required = true, HelpText = "Connection string for the ODS database in which to install the solution")]
        public string ConnectionString { get; set; }

        [Option('i', "includeIndexes", Required = false, Default = false, HelpText = "Install all analytics indexes")]
        public bool IncludeIndexes { get; set; }

        [Option('v', "includeViews", Required = false, Default = true, HelpText = "Install all analytics views")]
        public bool IncludeViews { get; set; }

        [Option('u', "uninstall", Required = false, Default = false, HelpText = "Uninstall all analytics views and indexes")]
        public bool Uninstall { get; set; }
    }
}
