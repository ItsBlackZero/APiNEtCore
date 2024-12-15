using BCSanJuan;
using ClinicaSanJuan.Shared;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Xml.Linq;
namespace ClinicaSanJuan.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CarroController : ControllerBase
    {
        private readonly ILogger<CarroController> _logger;
        public CarroController(ILogger<CarroController> logger)
        {
            _logger = logger;
        }
        [Route("[action]")]
        [HttpPost]
        public async Task<ActionResult<Carro>> GetCarro([FromBody]Carro carro)
        {

            var cadenaConexion = new ConfigurationBuilder().AddJsonFile("appsettings.json")
                .Build()
                .GetSection("ConnectionStrings")["CadenaSQL"];
            XDocument xmlParam = Shared.DBXmlMethods.GetXml(carro);
            DataSet dsResultado = await Shared.DBXmlMethods.EjecutaBase(Shared.NameStoreProcedure.SP_GetName1, cadenaConexion,carro.Transaccion, xmlParam.ToString());
            Console.WriteLine("XML" + xmlParam);
            List<Carro> carros = new List<Carro>();

            if (dsResultado.Tables.Count > 0) 
            {
                try
                {
                    Console.WriteLine("entro if");
                    foreach (DataRow row in dsResultado.Tables[0].Rows)
                    {
                        Carro objResponse = new Carro
                        {
                            modelo = row["modelo"].ToString(),
                            anio = Convert.ToInt32(row["anio"]),
                            color = row["color"].ToString(),
                            precio = Convert.ToDecimal(row["precio"]),
                            marca = new Marca()
                            {
                                Nombre = row["marca"].ToString(),
                            }

                        };
                        carros.Add(objResponse);
                    }
                }
                catch (Exception ex) 
                {
                    Console.WriteLine(ex.Message);
                }
        
            }
            Console.WriteLine("no entro");

            return Ok(carros);
        }


    }
}
